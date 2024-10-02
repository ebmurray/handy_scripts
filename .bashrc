# Change uuser's value to YOUR NAME, CLEAR it if you DON'T want the user or host to be static.
uuser=''
hhost=''

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=2000
HISTFILESIZE=2000

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Force colour prompt behaviour
force_colour_prompt=yes
if [ -n "$force_colour_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have colour support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        colour_prompt=yes
    else
        colour_prompt=
    fi
fi

# Set variable identifying the chroot you work in (used in the two-line prompt)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Change prompt colours based on root/not-root
    prompt_colour='\[\033[0;32m\]'
    info_colour='\[\033[1;34m\]'
    prompt_symbol=@
    if [ "$EUID" -eq 0 ]; then # Change prompt colours for root user
        prompt_colour='\[\033[0;94m\]'
        info_colour='\[\033[1;31m\]'
        # Emoji for root terminal
        #prompt_symbol=㉿
    fi

# Establish if user@host should be used, or the custom strings at the top
if [ ! "$uuser" ];then
    uuser='\u'
    hhost='\h'
    ttitle='\u@\h: \w'
else
    ttitle='$hhost: \w'
fi

# Git default-style PS1 without trailing newline
# PS1="\[\033]0;$TITLEPREFIX:$PWD\007\]\[\033[32m\]\u@\h \[\033[35m\]$MSYSTEM \[\033[33m\]\w\[\033[36m\]`__git_ps1`\[\033[0m\]$"

# Kali-style, two-line with variable user@host
# PS1=$prompt_colour'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename $VIRTUAL_ENV)'$prompt_colour')}('$info_colour'\u'$prompt_symbol'\h'$prompt_colour')-[\[\033[0;1m\]\w'$prompt_colour']\n'$prompt_colour'└─'$info_colour'\$\[\033[0m\] '

# Kali-style, two-line with specified, unchanging user@host
PS1=$prompt_colour'┌──${debian_chroot:+($debian_chroot)──}${VIRTUAL_ENV:+(\[\033[0;1m\]$(basename $VIRTUAL_ENV)'$prompt_colour')}('$info_colour$uuser$prompt_symbol$hhost$prompt_colour')-[\[\033[0;1m\]\w'$prompt_colour']\n'$prompt_colour'└─'$info_colour'\$\[\033[0m\] '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
PS1="\[\e]0;${debian_chroot:+($debian_chroot)}$ttitle\a\]$PS1"
    ;;
*)
    ;;
esac

# Enable colour support of ls, less and man, and add handy aliases
export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls colour for folders with 777 permissions

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias diff='diff --color=auto'
alias ip='ip --color=auto'

# Widespread ls aliases
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'