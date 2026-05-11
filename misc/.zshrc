[[ $- != *i* ]] && return

# =============================================================================
# ENVIRONMENT
# =============================================================================

export EDITOR="nvim"
export VISUAL="$EDITOR"
export BROWSER="zen-browser"
export TERMINAL="kitty"

export BAT_THEME="base16"
export SUDO_PROMPT="Deploying root access for %u. Password pls: "

export HISTORY_IGNORE="(ls|ll|la|pwd|exit|history|cd|cd -|cd ..)"

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# =============================================================================
# PATH
# =============================================================================

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

# =============================================================================
# ZSH OPTIONS
# =============================================================================

setopt AUTO_CD
setopt AUTO_LIST
setopt AUTO_MENU
setopt AUTO_PUSHD
setopt COMPLETE_IN_WORD
setopt EXTENDED_GLOB
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt INTERACTIVE_COMMENTS
setopt LIST_PACKED
setopt MENU_COMPLETE
setopt NO_BEEP
setopt NO_CLOBBER
setopt PROMPT_SUBST
setopt PUSHD_IGNORE_DUPS
setopt SHARE_HISTORY

# =============================================================================
# HISTORY
# =============================================================================

HISTFILE="$HOME/.config/zsh/zhistory"
HISTSIZE=100000
SAVEHIST=100000

# =============================================================================
# COMPLETION
# =============================================================================

autoload -Uz compinit
autoload -Uz add-zsh-hook
autoload -Uz vcs_info

zmodload zsh/complist

mkdir -p "$HOME/.cache/zsh"

local zcompdump="$HOME/.cache/zsh/zcompdump"

if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
  compinit -d "$zcompdump"
else
  compinit -C -d "$zcompdump"
fi

# Compile completion dump
if [[ -s "$zcompdump" ]]; then
  zcompile "$zcompdump"
fi

# Completion styles
zstyle ':completion:*' menu select

zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Z}' \
  '+r:|[._-]=* r:|=*' \
  '+l:|=*'

zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*:descriptions' format '[%d]'

_comp_options+=(globdots)

# =============================================================================
# FZF TAB
# =============================================================================

zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' accept-line enter

zstyle ':fzf-tab:*' fzf-flags \
  --height=90% \
  --layout=reverse \
  --border \
  --pointer='>' \
  --marker='*' \
  --preview-window='right:60%' \
  --color='pointer:green:bold' \
  --color='marker:yellow:bold' \
  --color='hl:blue:bold' \
  --color='hl+:magenta:bold'

zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza --icons --color=always -1 -a $realpath'

zstyle ':fzf-tab:complete:eza:*' fzf-preview \
  'eza --icons --color=always -1 -a $realpath'

zstyle ':fzf-tab:complete:bat:*' fzf-preview \
  'bat --color=always --style=numbers --theme=base16 $realpath'

# =============================================================================
# VCS
# =============================================================================

precmd() {
  vcs_info
}

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats \
  ' %B%F{magenta} %b%f'

# =============================================================================
# STARSHIP
# =============================================================================

export STARSHIP_CONFIG="$HOME/.config/starship.toml"

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# =============================================================================
# PLUGINS
# =============================================================================

plugins=(
  /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.zsh
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
)

for plugin in "${plugins[@]}"; do
  [[ -f "$plugin" ]] && source "$plugin"
done

# =============================================================================
# KEYBINDINGS
# =============================================================================

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Better tab animation
expand-or-complete-with-dots() {
  echo -n "\e[90m…\e[0m"
  zle expand-or-complete
  zle redisplay
}

zle -N expand-or-complete-with-dots
bindkey '^I' expand-or-complete-with-dots

# =============================================================================
# TERMINAL TITLE
# =============================================================================

function set-title-precmd() {
  print -Pn -- "\e]2;%n@%m:%~\a"
}

function set-title-preexec() {
  print -Pn -- "\e]2;${1:q}\a"
}

case "$TERM" in
  kitty*|alacritty*|tmux*|screen*|xterm*)
    add-zsh-hook precmd set-title-precmd
    add-zsh-hook preexec set-title-preexec
    ;;
esac

# =============================================================================
# ALIASES
# =============================================================================

# Editor
alias vim="$EDITOR"
alias vi="$EDITOR"
alias code="$EDITOR"

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Clear / Exit
alias c="clear"
alias q="exit"
alias :q="exit"

# File management
alias ls="eza --icons --group-directories-first"
alias l="ls -lh"
alias la="ls -lah"
alias lt="ls --tree"

alias cat="bat --paging=never --style=plain"
alias grep="grep --color=auto"

alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -Iv"

alias mkdir="mkdir -pv"

# Archives
alias mtar="tar -czvf"
alias utar="tar -xzvf"

alias z="zip -r"
alias uz="unzip"

# Pacman / Paru
alias pacman="sudo pacman --color auto"

alias i="paru -S"
alias r="paru -Rns"
alias s="paru -Ss"
alias u="paru -Syu"

alias update="paru -Syu"
alias clean="paru -Scc"

# Docker
alias docker-start="sudo systemctl start docker"
alias docker-stop="sudo systemctl stop docker"

# Misc
alias tree="tree -C"
alias sr="source ~/.config/zsh/env.zsh"

alias mkgrub="sudo grub-mkconfig -o /boot/grub/grub.cfg"

# =============================================================================
# PYTHON / VENV
# =============================================================================

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

# =============================================================================
# GIT
# =============================================================================

alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gp="git push"
alias gl="git pull"

# =============================================================================
# EXTRA
# =============================================================================

# Auto correct minor typos
ENABLE_CORRECTION="true"

# Better word movement
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

# alias nvw='NVIM_APPNAME=nvim-new nvim'
