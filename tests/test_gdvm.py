"""Exercise installer boundaries offline, without touching the user's setup."""

import errno
import os
from pathlib import Path
import pty
import select
import shutil
import signal
import subprocess
import tempfile
import time
import unittest


REPO = Path(__file__).resolve().parents[1]


class GdvmInstallTests(unittest.TestCase):
    def setUp(self):
        self.scratch = tempfile.TemporaryDirectory(prefix="gdvm-test-")
        self.addCleanup(self.scratch.cleanup)
        self.root = Path(self.scratch.name)
        self.task_home = self.root / "home with spaces"
        self.task_home.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.downloads = self.root / "downloads"
        self.downloads.mkdir()
        self.env = {
            "HOME": str(self.task_home),
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "TMPDIR": str(self.downloads),
            "SHELL": "/bin/zsh",
            "FIXTURE": str(self.root / "installer.sh"),
            "CALLS": str(self.root / "calls"),
        }
        self.command("uname", "printf 'Darwin\\n'\n")
        self.command("curl", """printf '%s\\n' "$*" >> "$CALLS"
while (( $# )); do
  if [[ "$1" == --output ]]; then output="$2"; shift; fi
  shift
done
cp "$FIXTURE" "$output"
exit "${DOWNLOAD_EXIT:-0}"
""")
        self.fixture = self.root / "installer.sh"
        self.fixture.write_text("""#!/usr/bin/env bash
set -eu
# Model upstream's profile-writing behaviour to catch repository mutations.
if [[ -n "${SHELL:-}" ]]; then
  printf 'profile changed\\n' >> "$HOME/.zshrc"
fi
mkdir -p "$HOME/.gdvm/bin"
printf '#!/bin/bash\\nprintf "gdvm fixture\\\\n"\\n' > "$HOME/.gdvm/bin/gdvm"
chmod +x "$HOME/.gdvm/bin/gdvm"
""")

    def command(self, name, body):
        target = self.bin / name
        target.write_text("#!/bin/bash\nset -eu\n" + body)
        target.chmod(0o755)

    def run_helper(self, terminal=True):
        command = ["/bin/bash", str(REPO / "scripts/install-gdvm.sh")]
        if not terminal:
            return subprocess.run(command, env=self.env, capture_output=True,
                                  text=True, start_new_session=True, timeout=10)
        pid, fd = pty.fork()
        if pid == 0:
            os.execve(command[0], command, self.env)
        output = bytearray()
        deadline = time.monotonic() + 10
        try:
            while True:
                if time.monotonic() >= deadline:
                    os.killpg(pid, signal.SIGKILL)
                    self.fail("Installer fixture timed out")
                if not select.select([fd], [], [], 0.1)[0]:
                    continue
                try:
                    chunk = os.read(fd, 65536)
                except OSError as error:
                    if error.errno == errno.EIO:
                        break
                    raise
                if not chunk:
                    break
                output.extend(chunk)
        finally:
            os.close(fd)
            _, status = os.waitpid(pid, 0)
        return subprocess.CompletedProcess(command, os.waitstatus_to_exitcode(status),
                                           output.decode(), "")

    def test_install_preserves_linked_profile_and_rerun_does_not_download(self):
        profile = self.root / "tracked-zshrc"
        profile.write_text("# managed profile\n")
        (self.task_home / ".zshrc").symlink_to(profile)
        result = self.run_helper()
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertEqual(profile.read_text(), "# managed profile\n")
        self.assertTrue((self.task_home / ".zshrc").is_symlink())
        calls = (self.root / "calls").read_text()
        self.assertIn("https://gdvm.io/install.sh", calls)
        self.assertEqual(list(self.downloads.iterdir()), [])
        result = self.run_helper(terminal=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.root / "calls").read_text(), calls)

    def test_failed_download_never_executes_partial_script(self):
        self.env["DOWNLOAD_EXIT"] = "22"
        result = self.run_helper()
        self.assertEqual(result.returncode, 22, result.stdout)
        self.assertFalse((self.task_home / ".gdvm").exists())
        self.assertEqual(list(self.downloads.iterdir()), [])

    def test_invalid_download_is_not_executed(self):
        self.fixture.write_text("mkdir -p \"$HOME/.gdvm\"\nif then\n")
        result = self.run_helper()
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertFalse((self.task_home / ".gdvm").exists())
        self.assertEqual(list(self.downloads.iterdir()), [])

    def test_upstream_failure_is_reported_and_tempfile_removed(self):
        self.fixture.write_text("exit 17\n")
        result = self.run_helper()
        self.assertEqual(result.returncode, 17, result.stdout)
        self.assertEqual(list(self.downloads.iterdir()), [])

    def test_existing_gdvm_on_path_is_left_alone(self):
        self.command("gdvm", "exit 0\n")
        result = self.run_helper(terminal=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.root / "calls").exists())

    def test_noninteractive_install_stops_before_download(self):
        result = self.run_helper(terminal=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("terminal", result.stderr)
        self.assertFalse((self.root / "calls").exists())

    def test_unsupported_platform_stops_before_download(self):
        self.command("uname", "printf 'Linux\\n'\n")
        result = self.run_helper(terminal=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("macOS", result.stderr)
        self.assertFalse((self.root / "calls").exists())

    def test_zsh_prefers_gdvm_without_duplicate_paths(self):
        gdvm_bin = self.task_home / ".gdvm/bin"
        gdvm_bin.mkdir(parents=True)
        self.command("godot", "printf 'fallback\\n'\n")
        (gdvm_bin / "godot").write_text("#!/bin/bash\nprintf 'managed\\n'\n")
        (gdvm_bin / "godot").chmod(0o755)
        (gdvm_bin / "gdvm").write_text(
            "#!/bin/bash\nprintf 'typeset -g gdvm_completion_loaded=yes\\n'\n"
        )
        (gdvm_bin / "gdvm").chmod(0o755)
        for profile in [".zprofile", ".zshrc"]:
            result = subprocess.run(
                [shutil.which("zsh"), "-dfic",
                 'source "$1"; source "$1"; godot; '
                 'print -r -- "$PATH"; print -r -- "${gdvm_completion_loaded:-no}"',
                 "test", str(REPO / profile)], env=self.env,
                capture_output=True, text=True, timeout=10,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            lines = result.stdout.splitlines()
            self.assertEqual(lines[0], "managed")
            path = lines[1].split(":")
            self.assertEqual(path[:2], [str(gdvm_bin), str(gdvm_bin / "current_godot")])
            self.assertEqual(path.count(str(gdvm_bin)), 1)
            if profile == ".zshrc":
                self.assertEqual(lines[2], "yes")

    def test_setup_installs_gdvm_by_default(self):
        checkout = self.root / "checkout"
        shutil.copytree(REPO, checkout, ignore=shutil.ignore_patterns(".git", "__pycache__"))
        spy = checkout / "scripts/install-gdvm.sh"
        spy.write_text('#!/bin/bash\nprintf "called\\n" >> "$CALLS"\n')
        result = subprocess.run(
            ["/bin/bash", str(checkout / "setup.sh"), "--skip-brew", "--skip-vscode"],
            env=self.env, capture_output=True, text=True, timeout=10,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.root / "calls").exists())


if __name__ == "__main__":
    unittest.main()
