##
## Aliases
##

# Use the same editor
alias vim='$EDITOR'
alias vi='$EDITOR'
alias code='$EDITOR'

# Suffix aliases (execute specific file types with desired tool)
alias edit='vim'              # Edit files with vim

#List
alias ls="eza --color=auto --icons"
alias l="ls -l"
alias ll="ls -a"
alias lla="ls -la"
alias lt="ls --tree"

#pacman unlock
alias unlock="sudo rm /var/lib/pacman/db.lck"
alias rmpacmanlock="sudo rm /var/lib/pacman/db.lck"

# aur helper
alias i="paru -S"
alias r="paru -Rns"
alias u="paru -Syu"
alias s="paru -Ss"
alias Q="paru -Q"

#cache clean
alias clean="paru -Scc"

# pacman or pm
alias pacman='sudo pacman --color auto'
alias update='sudo pacman -Syyu'
alias upgrade='paru -Syyu'

#add new fonts
alias update-fc='sudo fc-cache -fv'

#switch between bash and zsh
alias tobash="sudo chsh $USER -s /bin/bash && echo 'Now log out.'"
alias tozsh="sudo chsh $USER -s /bin/zsh && echo 'Now log out.'"
alias tofish="sudo chsh $USER -s /bin/fish && echo 'Now log out.'"

#Cleanup orphaned packages
alias cleanup='sudo pacman -Rns $(pacman -Qtdq)'


#fix obvious typo's
alias c="clear"
alias q="exit"
alias :q="exit"
alias mtar='tar -zcvf' # mtar <archive_compress>
alias utar='tar -zxvf' # utar <archive_decompress> <file_list>
alias z='zip -r' # z <archive_compress> <file_list>
alias uz='unzip' # uz <archive_decompress> -d <dir>
alias sr='source ~/.config/zsh/env.zsh'
alias ..="cd .."
alias mkdir="mkdir -p"
alias cat="bat --color always --plain"
alias grep='grep --color=auto'
alias mv='mv -v'
alias cp='cp -vr'
alias rm='rm -vr'


#clean caches
alias cleanram="sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'"

#grub update
alias mkgrub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

# other
alias py='python'
alias tree='tree -C'

# Activate virtual environment in current directory, otherwise try in the parent.
alias act='source venv/bin/activate || source ../venv/bin/activate'

# Wifi management
alias wifi-gui='nm-connection-editor'
alias wifi-tui='nmtui'

# git Aliases
alias commit="git add . && git commit -m"
alias push="git push"
# vim:ft=zsh
