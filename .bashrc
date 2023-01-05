### STANDARD BASH RC STUFF  ###



# backwards in history
bind '"[A":history-search-backward'
bind '"[B":history-search-forward'

# Add date and time to history
HISTTIMEFORMAT="%F %T "
HISTCONTROL=ignoreboth # don't put duplicate lines or lines starting with space in the history.
shopt -s histappend # append to the history file, don't overwrite it

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# default coloring
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
# COLORS
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx
# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White
Color_Off='\e[0m'       # Text Reset


# SSH shortcuts
export ozstar='avajpeyi@ozstar.swin.edu.au'
export compaspc='avi@mu00150555.physics.monash.edu'


source ~/.custom_functions
