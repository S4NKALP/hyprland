#!/usr/bin/env bash

#the main packages
install_stage=(
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
    lsd
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

# set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"


# Function to display the script logo
show_logo() {
	echo -en "

#####################################
#                                   #
#  @author      : 00xZ4CKX          #
#    GitHub    : @S4NKALP          #
#    Developer : Sankalp Tharu     #
#  﫥 Copyright : Sankalp Tharu     #
#                                   #
#####################################

Warning! Please do Backup before going ahead. Do at your own risk.

"
}

# function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null;
    do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

# function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if paru -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        # no package found so installing
        echo -en "$CNT - Now installing $1 ."
        paru -S --noconfirm $1 &>> $INSTLOG &
        show_progress $!
        # test to make sure package installed
        if paru -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K$COK - $1 was installed."
        else
            # if this is hit then a package is missing, exit to review log
            echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
            exit
        fi
    fi
}

# clear the screen
clear

# Display the logo
show_logo
sleep 1

# let the user know that we will use sudo
echo -e "$CNT - This script will run some commands that require sudo. You will be prompted to enter your password.
If you are worried about entering your password then you may want to review the content of the script."
sleep 1

# give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
    echo -e "$CNT - Setup starting..."
else
    echo -e "$CNT - This script will now exit, no changes were made to your system."
    exit
fi

### Install all of the above pacakges ####
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to install the packages? (y,n) ' INST
if [[ $INST == "Y" || $INST == "y" ]]; then

    # Stage 1 - main components
    echo -e "$CNT - Installing main components, this may take a while..."
    for SOFTWR in ${install_stage[@]}; do
        install_software $SOFTWR
    done

    # Start the bluetooth service
    echo -e "$CNT - Starting the Bluetooth Service..."
    sudo systemctl enable --now bluetooth.service &>> $INSTLOG
    sleep 2

    # Enable the sddm login manager service
    echo -e "$CNT - Enabling the SDDM Service..."
    sudo systemctl enable sddm &>> $INSTLOG
    sleep 2

fi

### Copy Config Files ###
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to copy config files? (y,n) ' CFG
if [[ $CFG == "Y" || $CFG == "y" ]]; then
    echo -e "$CNT - Copying config files..."

    # copying wallpapers
    cp -r wallpapers ~/Pictures
    cp -r config/* ~/.config
    mkdir -p ~/.local
    cp -r misc/bin ~/.local
    cp -r misc/.zshenv ~/

    # giving permissions
    chmod +x ~/.config/hypr/scripts/*

    # installing gtk themes
    git clone https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git
    sudo cp -r Tokyo-Night-GTK-Theme/themes/Tokyonight-Dark-BL-LB /usr/share/themes/
    sudo cp -r Tokyo-Night-GTK-Theme/icons/Tokyonight-Dark /usr/share/icons/

    sudo tar -xf "assets/Bibata-Modern-Ice.tar.xz" -C /usr/share/icons/

    echo -e "$CNT - Copying successful!"
fi

