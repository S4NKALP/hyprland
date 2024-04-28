<div align = "center">

<h1><a href="https://github.com/S4NKALP/hyprland">hyprland</a></h1>

<a href="https://github.com/S4NKALP/hyprland/blob/main/LICENSE">
<img alt="License" src="https://img.shields.io/github/license/S4NKALP/hyprland?style=flat&color=eee&label="> </a>

<a href="https://github.com/S4NKALP/hyprland/graphs/contributors">
<img alt="People" src="https://img.shields.io/github/contributors/S4NKALP/hyprland?style=flat&color=ffaaf2&label=People"> </a>

<a href="https://github.com/S4NKALP/hyprland/stargazers">
<img alt="Stars" src="https://img.shields.io/github/stars/S4NKALP/hyprland?style=flat&color=98c379&label=Stars"></a>

<a href="https://github.com/S4NKALP/hyprland/network/members">
<img alt="Forks" src="https://img.shields.io/github/forks/S4NKALP/hyprland?style=flat&color=66a8e0&label=Forks"> </a>

<a href="https://github.com/S4NKALP/hyprland/watchers">
<img alt="Watches" src="https://img.shields.io/github/watchers/S4NKALP/hyprland?style=flat&color=f5d08b&label=Watches"> </a>

<a href="https://github.com/S4NKALP/hyprland/pulse">
<img alt="Last Updated" src="https://img.shields.io/github/last-commit/S4NKALP/hyprland?style=flat&color=e06c75&label="> </a>

<h3>Hyprland Dots As I use for my daily driver<h3>


<figure>
  <img src="assets/Rice.png" alt="hyprland" width="400">
  <img src="assets/Rofi.png" alt="rofi" width="300">
  <br/>
</figure>


</div>

### ✨ Features

- :dark_sunglasses: Dark Mode for the Whole System
- :bell: Notification Center
- :framed_picture: Various Wallpapers
- :nerd_face: Nerd Fonts for the Shell Prompt
- :loud_sound: Volume OSD
- :iphone: App Launcher
- :keyboard: Multiple Keyboard Layouts
- :car: Automatic mount of USB devices with notification
- :lock: Idle and lock apps
- :open_file_folder: Following XDG Base Directory Standard
- :broom: Organized and cleaned up config files
- :point_up: Screenshot, Clipboard and Wallpaper Picker
- :boom: Performance Mode
- :window: Window Animations
- :gear: Various other tweaks & scripts

---

### 🌸 Core System Info

- **OS**: [Arch Linux](https://archlinux.org/) :boom:
- **WM**: [hyprland](https://hyprland.org/) :window:
- **Shell**: [zsh](https://www.zsh.org/) / [starship](https://github.com/starship/starship) :shell:
- **Terminal Emulator**: [kitty](https://sw.kovidgoyal.net/kitty/) :cat:
- **Panel**: [waybar](https://github.com/Alexays/Waybar) :shaved_ice:
- **Text Editor**: [neovim](https://neovim.io/) :keyboard:
- **App Launcher**: [rofi](https://davatorium.github.io/rofi/) :rocket:
- **File Manager**: [yazi](https://yazi-rs.github.io/) / [Thunar](https://github.com/neilbrown/thunar) :open_file_folder:
- **Browser**: [firefox](https://www.mozilla.org/) / [qutebrowser](https://github.com/qutebrowser/qutebrowser) :globe_with_meridians:
- **Notification Manager**: [swaync](https://github.com/ErikReider/SwayNotificationCenter) :bell:
- **Colorscheme**: [Dracula](https://github.com/dracula/dracula-theme) :art:

---

# :wrench: ‎ <samp>Setup</samp>

<b> ArchInstall </b>
* Using ArchInstall Script Install Archlinux on bare metal.
* After Booting into HyprLand, Open terminal and install Aur Helper called Paru

<b> Install Paru (Aur Helper)</b>

```
git clone https://aur.archlinux.org/paru-bin.git
```
* cd paru-bin

* makepkg -Si

### :package: <samp>Automatic Installation (Arch Linux)</samp>

```
curl https://raw.githubusercontent.com/S4NKALP/hyprland/main/Installer.sh -o $HOME/Installer
chmod +x Installer.sh
./Installer
```


<h1><b> :package: Manual Installation </b></h1>

 <b> Dependency

```
paru -S fnm hyprland keyb rofi-file-browser-extended-git imv brightnessctl yazi waybar playerctl wf-recorder kvantum swaylock-effects-git qt5ct qt6ct nwg-look mpv-mpris pacman-contrib swayidle pavucontrol pamixer file-roller adobe-source-code-pro-fonts ttf-fira-code ttf-jetbrains-mono-nerd ttf-jetbrains-mono noto-fonts-emoji otf-font-awesome ttf-cascadia-code-nerd ttf-bitstream-vera ttf-croscore ttf-dejavu ttf-droid ttf-ibm-plex ttf-liberation noto-fonts gnu-free-fonts linux-headers alsa-utils less wlroots thunar thunar-volman thunar-archive-plugin udiskie mtpfs jmtpfs gvfs-gphoto2 gvfs-mtp rofi-lbonn-wayland-git network-manager-applet lsd cava geany geany-plugin swaync tumbler unzip zip unrar polkit-gnome xdg-user-dirs grim slurp jq polkit-kde-agent zathura-pdf-mupdf zathura yt-dlp ffmpegthumbnailer xdotool wmctrl zsh lazygit xdg-desktop-portal-gtk gtk-engine-murrine lxappearance xsel bc clipshit bluez bluez-utils swww kitty imagemagick
```

<b> Install GTK Themes,Icons,Cursor


* Dotfiles

```
cd Downloads
git clone https://github.com/S4NKALP/hyprland.git

cd hyprland
cp -r wallpapers ~/Pictures
cp -r config/* ~/.config
cp -r misc/bin ~/.local
cp -r misc/.zshenv ~/

chmod +x ~/.config/hypr/scripts/*
```

* GTK Themes

 ```
git clone https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git
sudo cp -r Tokyo-Night-GTK-Theme/themes/Tokyonight-Dark-BL-LB /usr/share/themes/
sudo cp -r Tokyo-Night-GTK-Theme/icons/Tokyonight-Dark /usr/share/icons/

sudo tar -xf "assets/Bibata-Modern-Ice.tar.xz" -C /usr/share/icons/
```
<hr>

### 🧰 Tools Used

- [qute](https://github.com/S4NKALP/qute) — Personalized Browser
- [nvim](https://github.com/S4NKALP/nvim) — Personalized Editor

<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

</div>





