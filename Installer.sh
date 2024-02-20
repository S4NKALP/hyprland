#!/usr/bin/env bash


CRE=$(tput setaf 1)
CYE=$(tput setaf 3)
CGR=$(tput setaf 2)
CBL=$(tput setaf 4)
BLD=$(tput bold)
CNC=$(tput sgr0)

backup_folder=~/.RiceBackup
date=$(date +%Y%m%d-%H%M%S)
log_file=installer_log.txt

# Function to log message
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$log_file"
}

# Redirect stdout and stderr to the log file
exec > >(tee -a "$log_file") 2>&1

# Function to display logo
logo () {

	local text="${1:?}"
	echo -en "

#####################################
#                                   #
#  @author      : 00xZ4CKX          #
#    GitHub    : @S4NKALP          #
#    Developer : Sankalp Tharu     #
#  﫥 Copyright : Sankalp Tharu     #
#                                   #
#####################################
"
printf ' %s [%s%s %s%s %s]%s\n\n' "${CRE}" "${CNC}" "${CYE}" "${text}" "${CNC}" "${CRE}" "${CNC}"
}

########## ---------- You must not run this as root ---------- ##########

if [ "$(id -u)" = 0 ]; then
    echo "This script MUST NOT be run as root user."
    exit 1
fi

########## ---------- Welcome ---------- ##########

logo "Welcome!"
printf '%s%sThis script will check if you have the necessary dependencies, and if not, it will install them. Then, it will clone the RICE in your HOME directory.\nAfter that, it will create a secure backup of your files, and then copy the new files to your computer.\nYou will be prompted for your root password to install missing dependencies and/or to switch to zsh shell if its not your default.It will generate log file.\n\nThis script doesnt have the potential power to break your system, it only copies files from my repository to your HOME directory.%s\n\n' "${BLD}" "${CRE}" "${CNC}"

while true; do
	read -rp " Do you wish to continue? [y/N]: " yn
		case $yn in
			[Yy]* ) break;;
			[Nn]* ) exit;;
			* ) printf " Error: just write 'y' or 'n'\n\n";;
		esac
    done
clear

########## ---------- Install packages ---------- ##########

logo "Installing needed packages.."

dependencias=(
    hyprland
    fnm
    keyb
    rofi-file-browser-extended-git
    imv
    brightnessctl
    yazi
    waybar
    playerctl
    wf-recorder
    kvantum
    swaylock-effects-git
    qt5ct
    qt6ct
    nwg-look
    mpv-mpris
    pacman-contrib
    swayidle
    pavucontrol
    pamixer
    file-roller
    alsa-utils
    linux-headers
    less
    wlroots
    thunar
    thunar-volman
    thunar-archive-plugin
    udiskie
    mtpfs
    jmtpfs
    gvfs-gphoto2
    gvfs-mtp
    rofi-lbonn-wayland-git
    network-manager-applet
    cava
    geany
    geany-plugin
    swaync
    tumbler
    unzip
    zip
    unrar
    polkit-gnome
    xdg-user-dirs
    clipshit
    swww
    kitty
    imagemagick
    bluez
    bluez-utils
    grim
    slurp
    jq
    zathura
    zathura-pdf-mupdf
    yt-dlp
    ffmpegthumbnailer
    xdotool
    wmctrl
    zsh
    lazygit
    xdg-desktop-portal-gtk
    gtk-engine-murrine
    lxappearance
    xsel
    bc
    vesktop-bin
    sddm
    adobe-source-code-pro-fonts
    ttf-fira-code
    ttf-jetbrains-mono-nerd
    ttf-jetbrains-mono
    noto-fonts-emoji
    ttf-droid
    otf-font-awesome
    ttf-cascadia-code-nerd
    ttf-bitstream-vera
    ttf-croscore
    ttf-dejavu
    ttf-ibm-plex
    ttf-liberation
    noto-fonts
    gnu-free-fonts
)

is_installed() {
  paru -Qi "$1" &> /dev/null
  return $?
}

printf "%s%sChecking for required packages...%s\n" "${BLD}" "${CBL}" "${CNC}"
for paquete in "${dependencias[@]}"
do
  if ! is_installed "$paquete"; then
    paru -S "$paquete" --noconfirm
    printf "\n"
  else
    printf '%s%s is already installed on your system!%s\n' "${CGR}" "$paquete" "${CNC}"
    sleep 1
  fi
done
sleep 3
clear

########## ---------- Preparing Folders ---------- ##########

# Check if the file user-dirs.dirs does not exist in ~/.config
	if [ ! -e "$HOME/.config/user-dirs.dirs" ]; then
		xdg-user-dirs-update
		echo "Creating xdg-user-dirs"
	fi
sleep 2
clear

########## ---------- Cloning the Rice! ---------- ##########

logo "Downloading dotfiles"

repo_url="https://github.com/S4NKALP/hyprland"
repo_dir="$HOME/dotfiles"

# Checks if the repository directory already exists and if so, deletes it
	if [ -d "$repo_dir" ]; then
		printf "Removing existing dotfiles repository\n"
		rm -rf "$repo_dir"
	fi

# Clona el repositorio
printf "Cloning dotfiles from %s\n" "$repo_url"
git clone --depth=1 "$repo_url" "$repo_dir"

sleep 2
clear

########## ---------- Backup files ---------- ##########

logo "Backup files"
printf "Backup files will be stored in %s%s%s/.RiceBackup%s \n\n" "${BLD}" "${CRE}" "$HOME" "${CNC}"
sleep 10

if [ ! -d "$backup_folder" ]; then
  mkdir -p "$backup_folder"
fi

for folder in BetterDiscord cava geany hypr keyb kitty Kvantum lazygit lsd mpv neofetch nvim qimgv qt5ct qt6ct rofi starship swaylock swaync Thunar VSCodium waybar yazi zathura zsh; do
  if [ -d "$HOME/.config/$folder" ]; then
    mv "$HOME/.config/$folder" "$backup_folder/${folder}_$date"
    echo "$folder folder backed up successfully at $backup_folder/${folder}_$date"
  else
    echo "The folder $folder does not exist in $HOME/.config/"
  fi
done

[ -f ~/.zshrc ] && mv ~/.zshrc ~/.RiceBackup/.zshrc-backup-"$(date +%Y.%m.%d-%H.%M.%S)"

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 5

########## ---------- Copy the Rice! ---------- ##########

logo "Installing dotfiles.."
printf "Copying files to respective directories..\n"

[ ! -d ~/.config ] && mkdir -p ~/.config
[ ! -d ~/.local/bin ] && mkdir -p ~/.local/bin
[ ! -d ~/Pictures/wallpapers ] && mkdir -p ~/Pictures/wallpapers

for archivos in ~/dotfiles/config/*; do
  cp -R "${archivos}" ~/.config/
  if [ $? -eq 0 ]; then
	printf "%s%s%s folder copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/misc/bin/*; do
  cp -R "${archivos}" ~/.local/bin/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/misc/.zshenv; do
  cp -R "${archivos}" ~/
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

for archivos in ~/dotfiles/wallpapers/*; do
  cp -R "${archivos}" ~/Pictures/wallpapers
  if [ $? -eq 0 ]; then
	printf "%s%s%s file copied succesfully!%s\n" "${BLD}" "${CGR}" "${archivos}" "${CNC}"
	sleep 1
  else
	printf "%s%s%s failed to been copied, you must copy it manually%s\n" "${BLD}" "${CRE}" "${archivos}" "${CNC}"
	sleep 1
  fi
done

printf "%s%sFiles copied succesfully!!%s\n" "${BLD}" "${CGR}" "${CNC}"
sleep 3


########## ---------- Enabling Bluetooth service ---------- ##########

logo "Enabling bluetooth service"

# Check if the bluetooth service is enabled
if systemctl is-enabled --quiet bluetooth.service; then
    printf "\n%s%sDisabling and stopping the Bluetooth service%s\n" "${BLD}" "${CBL}" "${CNC}"
    sudo systemctl stop bluetooth.service
    sudo systemctl disable bluetooth.service
fi

printf "\n%s%sEnabling bluetooth service%s\n" "${BLD}" "${CYE}" "${CNC}"
sudo systemctl enable --now bluetooth.service

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2

########## --------- Enabling Sddm service ---------- ##########

logo "Enabling sddm service"

# Chech if the sddm service is enabled
if systemctl is-enabled --quiet sddm.service; then
    printf "\n%s%sDisabling and stopping the SDDM service%s\n" "${BLD}" "${CBL}" "${CNC}"
    sudo systemctl stop sddm.service
    sudo systemctl disable sddm.service
fi

printf "\n%s%sEnabling sddm service%s\n" "${BLD}" "${CYE}" "${CNC}"
sudo systemctl enable sddm

printf "%s%sDone!!%s\n\n" "${BLD}" "${CGR}" "${CNC}"
sleep 2

########## --------- Installing GTK THMES ---------- ##########

logo "Installing GTK THMES"

    git clone https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git
    sudo cp -r Tokyo-Night-GTK-Theme/themes/Tokyonight-Dark-BL-LB /usr/share/themes/
    sudo cp -r Tokyo-Night-GTK-Theme/icons/Tokyonight-Dark /usr/share/icons/
    sudo tar -xf "assets/Bibata-Modern-Ice.tar.xz" -C /usr/share/icons/


########## --------- Changing shell to zsh ---------- ##########

logo "Changing default shell to zsh"

	if [[ $SHELL != "/usr/bin/zsh" ]]; then
		printf "\n%s%sChanging your shell to zsh. Your root password is needed.%s\n\n" "${BLD}" "${CYE}" "${CNC}"
		# Change the shell to zsh
		chsh -s /usr/bin/zsh
		printf "%s%sShell changed to zsh. Please reboot.%s\n\n" "${BLD}" "${CGR}" "${CNC}"
	else
		printf "%s%sYour shell is already zsh\nGood bye! installation finished, now reboot%s\n" "${BLD}" "${CGR}" "${CNC}"
	fi
zsh
