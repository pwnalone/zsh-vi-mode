readonly _ZVM_CMD='cmd'
readonly _ZVM_INS='ins'
readonly _ZVM_REP='rep'
readonly _ZVM_OTH='oth'

function zvm
{
    case $KEYMAP in
        viins|main)
            if [[ $ZLE_STATE == *overwrite* ]]; then
                printf $_ZVM_REP
            elif [[ $ZLE_STATE == *insert*  ]]; then
                printf $_ZVM_INS
            else
                printf $_ZVM_OTH
            fi
	    ;;
        vicmd)
            printf $_ZVM_CMD
	    ;;
    esac
}

function zvm-backward-delete-char
{
    if [[ $(zvm) != $_ZVM_REP ]]; then
        zle backward-delete-char
    else
        if ((CURSOR <= MARK)); then
            if ((CURSOR > 0)); then
                CURSOR=$((CURSOR-1))
                MARK=$CURSOR
            fi
        else
            zle undo
        fi
    fi
}

function zle-line-init zle-keymap-select
{
    case $(zvm) in
        $_ZVM_CMD)
            printf "\e[2 q"
            ;;
        $_ZVM_INS)
            printf "\e[6 q"
            ;;
        $_ZVM_REP)
            printf "\e[4 q"
            MARK=$CURSOR
            ;;
        $_ZVM_OTH)
            ;;
    esac
}

zle -N zvm-backward-delete-char
zle -N zle-line-init
zle -N zle-keymap-select

bindkey -v

export KEYTIMEOUT=1

if [[ -o AUTO_MENU ]] || [[ -o MENU_COMPLETE ]]; then
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
fi

bindkey '^?' zvm-backward-delete-char
