# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#  ┬  ┬┌─┐┬─┐┌─┐
#  └┐┌┘├─┤├┬┘└─┐
#   └┘ ┴ ┴┴└─└─┘
export VISUAL="${EDITOR}"
export EDITOR='nvim'
export BROWSER='zen-browser'
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd ..)"
export SUDO_PROMPT="Deploying root access for %u. Password pls: "
export BAT_THEME="base16"

export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

typeset -U path PATH

path=(
  "$HOME/.local/bin"
  "$ANDROID_HOME/emulator"
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/tools"
  "$ANDROID_HOME/tools/bin"
  $path
)

export PATH

#  ┬  ┌─┐┌─┐┌┬┐  ┌─┐┌┐┌┌─┐┬┌┐┌┌─┐
#  │  │ │├─┤ ││  ├┤ ││││ ┬││││├┤
#  ┴─┘└─┘┴ ┴─┴┘  └─┘┘└┘└─┘┴┘└┘└─┘
autoload -Uz compinit

mkdir -p "$HOME/.cache/zsh"

local zcompdump="$HOME/.config/zsh/zcompdump"

if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
    compinit -i -d "$zcompdump"
else
    compinit -C -d "$zcompdump"
fi

if [[ ! -f "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc" ]]; then
    zcompile -U "$zcompdump"
fi


autoload -Uz add-zsh-hook
autoload -Uz vcs_info
precmd () { vcs_info }
_comp_options+=(globdots)

zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list \
		'm:{a-zA-Z}={A-Za-z}' \
		'+r:|[._-]=* r:|=*' \
		'+l:|=*'
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'
zstyle ':fzf-tab:*' fzf-flags --style=full --height=90% --pointer '>' --gutter ' ' \
                    --color 'pointer:green:bold,bg+:-1:,fg+:green:bold,info:blue:bold,marker:yellow:bold,hl:gray:bold,hl+:gray:bold' \
                    --input-label ' Search ' --color 'input-border:blue,input-label:blue:bold' \
                    --list-label ' Results ' --color 'list-border:green,list-label:green:bold' \
                    --preview-label ' Preview ' --preview-label-pos '27:bottom' --color 'preview-border:magenta,preview-label:magenta:bold'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:eza:*' fzf-preview 'eza -1 --icons=always --color=always -a $realpath'
zstyle ':fzf-tab:complete:bat:*' fzf-preview 'bat --color=always --theme=base16 $realpath'
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter

#  ┬ ┬┌─┐┬┌┬┐┬┌┐┌┌─┐  ┌┬┐┌─┐┌┬┐┌─┐
#  │││├─┤│ │ │││││ ┬   │││ │ │ └─┐
#  └┴┘┴ ┴┴ ┴ ┴┘└┘└─┘  ─┴┘└─┘ ┴ └─┘
expand-or-complete-with-dots() {
  echo -n "\e[31m…\e[0m"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

#  ┬ ┬┬┌─┐┌┬┐┌─┐┬─┐┬ ┬
#  ├─┤│└─┐ │ │ │├┬┘└┬┘
#  ┴ ┴┴└─┘ ┴ └─┘┴└─ ┴
HISTFILE=~/.config/zsh/zhistory
HISTSIZE=5000
SAVEHIST=5000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

#  ┌─┐┌─┐┬ ┬  ┌─┐┌─┐┌─┐┬    ┌─┐┌─┐┌┬┐┬┌─┐┌┐┌┌─┐
#  ┌─┘└─┐├─┤  │  │ ││ ││    │ │├─┘ │ ││ ││││└─┐
#  └─┘└─┘┴ ┴  └─┘└─┘└─┘┴─┘  └─┘┴   ┴ ┴└─┘┘└┘└─┘
setopt AUTOCD              # change directory just by typing its name
setopt PROMPT_SUBST        # enable command substitution in prompt
setopt MENU_COMPLETE       # Automatically highlight first element of completion menu
setopt LIST_PACKED		   # The completion menu takes less space.
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD    # Complete from both ends of a word.

#  ┌┬┐┬ ┬┌─┐  ┌─┐┬─┐┌─┐┌┬┐┌─┐┌┬┐
#   │ ├─┤├┤   ├─┘├┬┘│ ││││├─┘ │
#   ┴ ┴ ┴└─┘  ┴  ┴└─└─┘┴ ┴┴   ┴
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

if [[ $- == *i* ]] && command -v starship >/dev/null 2>&1; then
	eval "$(starship init zsh)"
fi

if [[ $- == *i* ]] && command -v zoxide >/dev/null 2>&1; then
	eval "$(zoxide init zsh)"
fi

#  ┌─┐┬  ┬ ┬┌─┐┬┌┐┌┌─┐
#  ├─┘│  │ ││ ┬││││└─┐
#  ┴  ┴─┘└─┘└─┘┴┘└┘└─┘
source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

#  ┌─┐┬ ┬┌─┐┌┐┌┌─┐┌─┐  ┌┬┐┌─┐┬─┐┌┬┐┬┌┐┌┌─┐┬  ┌─┐  ┌┬┐┬┌┬┐┬  ┌─┐
#  │  ├─┤├─┤││││ ┬├┤    │ ├┤ ├┬┘│││││││├─┤│  └─┐   │ │ │ │  ├┤
#  └─┘┴ ┴┴ ┴┘└┘└─┘└─┘   ┴ └─┘┴└─┴ ┴┴┘└┘┴ ┴┴─┘└─┘   ┴ ┴ ┴ ┴─┘└─┘
function xterm_title_precmd () {
	print -Pn -- '\e]2;%n@%m %~\a'
	[[ "$TERM" == 'screen'* ]] && print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-}\e\\'
}

function xterm_title_preexec () {
	print -Pn -- '\e]2;%n@%m %~ %# ' && print -n -- "${(q)1}\a"
	[[ "$TERM" == 'screen'* ]] && { print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-} %# ' && print -n -- "${(q)1}\e\\"; }
}

if [[ "$TERM" == (kitty*|alacritty*|tmux*|screen*|xterm*) ]]; then
	add-zsh-hook -Uz precmd xterm_title_precmd
	add-zsh-hook -Uz preexec xterm_title_preexec
fi


#  ┌─┐┬  ┬┌─┐┌─┐
#  ├─┤│  │├─┤└─┐
#  ┴ ┴┴─┘┴┴ ┴└─┘
if command -v trash-put > /dev/null 2>&1; then
	alias rm='trash-put'
elif command -v trash > /dev/null 2>&1; then
	alias rm='trash -v'
elif command -v gio > /dev/null 2>&1; then
	alias rm='gio trash'
else
	alias rm='rm -i'
fi

# Navigation
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Clear / Exit
alias c="clear"
alias cls='clear'
alias q="exit"
alias :q="exit"

# File management
alias ls='eza --icons --group-directories-first'
alias l='ls -lh'
alias la='ls -lah'
alias ll='ls -lah --git'
alias lla='ls -lah'
alias lls='ls -lh'
alias las='ls -a'
alias lt='eza --tree --icons --group-directories-first'
alias ltr='eza --tree --level=2 --icons --group-directories-first'
alias lx='eza -lh --sort=extension --group-directories-first --icons'
alias lk='eza -lh --sort=size --group-directories-first --icons'
alias lc='eza -lh --sort=changed --group-directories-first --icons'
alias lu='eza -lh --sort=accessed --group-directories-first --icons'
alias labc='eza -lh --sort=name --group-directories-first --icons'
alias ltime='eza -lh --sort=modified --group-directories-first --icons'
alias lr='eza -lh -R --icons'
alias lf='eza -lh --only-files --icons'
alias ldir='eza -lh --only-dirs --icons'
alias lw='eza -1 --icons --group-directories-first'

# Chmod
alias mx='chmod a+x'
alias 000='chmod -R 000'
alias 644='chmod -R 644'
alias 666='chmod -R 666'
alias 755='chmod -R 755'
alias 777='chmod -R 777'

# Overrides
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ps='ps auxf'
alias ping='ping -c 10'
alias less='less -R'
alias cat="bat --paging=never --style=plain"
alias grep="grep --color=auto"
alias tree="tree -C"


# Archives
alias mktar='tar -cvf'
alias mkbz2='tar -cvjf'
alias mkgz='tar -cvzf'
alias untar='tar -xvf'
alias unbz2='tar -xvjf'
ungz() {
    tar -xvzf "$@"
}

# Docker
docker-clean() {
    command -v docker >/dev/null || {
        echo "docker is not installed."
        return 1
    }

    docker system prune -af --volumes
}

alias dockerstart="sudo systemctl start docker"
alias dockerstop="sudo systemctl stop docker"
alias dockerrestart='sudo systemctl restart docker'
alias dockerstatus='systemctl status docker'
alias dockerenable='sudo systemctl enable --now docker'

# Extract
extract() {
	for archive in "$@"; do
		if [ -f "$archive" ]; then
			case $archive in
			*.tar.bz2) tar xvjf "$archive" ;;
			*.tar.gz) tar xvzf "$archive" ;;
			*.bz2) bunzip2 "$archive" ;;
			*.rar) rar x "$archive" ;;
			*.gz) gunzip "$archive" ;;
			*.tar) tar xvf "$archive" ;;
			*.tbz2) tar xvjf "$archive" ;;
			*.tgz) tar xvzf "$archive" ;;
			*.zip) unzip "$archive" ;;
			*.Z) uncompress "$archive" ;;
			*.7z) 7z x "$archive" ;;
			*) echo "don't know how to extract '$archive'..." ;;
			esac
		else
			echo "'$archive' is not a valid file!"
		fi
	done
}

# System
cd() {
    builtin cd "${1:-$HOME}" || return
    eza --icons --group-directories-first
}

update() {
    if command -v paru >/dev/null 2>&1; then
        paru -Syu "$@"
    elif command -v yay >/dev/null 2>&1; then
        yay -Syu "$@"
    else
        sudo pacman -Syu "$@"
    fi
}

clean() {
    if command -v paru >/dev/null 2>&1; then
        paru -Scc "$@"
    elif command -v yay >/dev/null 2>&1; then
        yay -Scc "$@"
    else
        sudo pacman -Scc "$@"
    fi
}


# Network
alias whatismyip="whatsmyip"
function whatsmyip () {
	# Internal IP Lookup.
	echo -n "Internal IP: "
	if command -v ip >/dev/null 2>&1; then
		ip -o -4 route get 1.1.1.1 2>/dev/null | awk '{for (i=1; i<=NF; i++) if ($i == "src") {print $(i+1); exit}}'
	elif command -v ifconfig >/dev/null 2>&1; then
		ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}'
	else
		echo "unknown"
	fi

	# External IP Lookup
	echo -n "External IP: "
	if command -v curl >/dev/null 2>&1; then
		curl -4fsS --max-time 5 https://icanhazip.com || echo "unknown"
	else
		echo "curl not installed"
	fi
}


# PYTHON / VENV
venv() {
  local env_dir=".venv"

  if [[ ! -d "$env_dir" ]]; then
    python -m venv "$env_dir"
    echo "Created virtual environment"
  fi

  source "$env_dir/bin/activate"
  echo "Activated: $env_dir"
}

act() {
  local dir="$PWD"

  while [[ "$dir" != "/" ]]; do
    for env in ".venv" "venv"; do
      if [[ -f "$dir/$env/bin/activate" ]]; then
        source "$dir/$env/bin/activate"
        echo "Activated: $dir/$env"
        return
      fi
    done

    dir="$(dirname "$dir")"
  done

  echo "No virtual environment found"
}

# Package Manager
if command -v fzf >/dev/null 2>&1; then
    if command -v yay >/dev/null 2>&1; then
        alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"
    fi

    if command -v paru >/dev/null 2>&1; then
        alias paruf="paru -Slq | fzf --multi --preview 'paru -Sii {1}' --preview-window=down:75% | xargs -ro paru -S"
    fi

    if command -v pacman >/dev/null 2>&1; then
        alias pacf="pacman -Slq | fzf --multi --preview 'pacman -Si {1}' --preview-window=down:75% | xargs -ro sudo pacman -S"
    fi
fi
