# >>> BASHRC PROMPT INIT >>>
getRoot () {
    echo "$(echo ~)"
}

if [ -f $(getRoot)/.config/gr8sh/prompt.sh ] && [ -n "$( echo $- | grep i )" ]; then
        source $(getRoot)/.config/gr8sh/prompt.sh
fi
# <<< BASHRC PROMPT INIT <<<

# >>> ALIASES >>>
alias cls="clear"
alias lsa="ls -a"
alias update="sudo apt update"
alias upgrade="sudo apt upgrade"
alias upgradable="apt list --upgradable"
# <<< ALIASES <<<
