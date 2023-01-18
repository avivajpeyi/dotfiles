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


# SSH shortcuts
export ozstar='avajpeyi@ozstar.swin.edu.au'
export compaspc='avi@mu00150555.physics.monash.edu'


source ~/.custom_functions
source ~/.bash_aliases
eval "$(starship init bash)"
