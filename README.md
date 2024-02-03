# :herb: ‎ <samp>About</samp>

Hey there! :wave:

This is my personal dotfiles repository. A simple aesthetic (at least for me). I edited [JakooLit](https://github.com/JaKooLit/Hyprland-Dots) dotfiles for Hyprland for my base rice but without pywal


### ✨ Features

- :bell: Notification Center
- :zzz: Neovim powered by LazyVim with custom extras added (More than 200!)
- :dark_sunglasses: Dark Mode for the whole system
- :framed_picture: Various Wallpapers
- :nerd_face: Nerd Fonts for the Shell Prompt
- :rocket: VSCodium with native integration of your Neovim setup
- :loud_sound: Volume OSD
- :iphone: App Launcher
- :keyboard: Multiple Keyboard Layouts
- :art: Color scripts for the terminal
- :car: Automatic mount of USB devices with notification
- :lock: Idle and lock apps
- :open_file_folder: Following XDG Base Directory Standard
- :broom: Organized and cleaned up config files
- :film_projector: Recording script
- :point_up: Screenshot, Clipboard and Wallpaper Picker
- :boom: Performance Mode
- :window: Window Animations
- :gear: Various other tweaks & scripts

---

### 🌸 Core System Info

- **OS**: [Arch Linux](https://archlinux.org/) :boom:
- **WM**: [hyprland](https://hyprland.org/) :window:
- **Shell**: [zsh](https://www.zsh.org/) [starship](https://github.com/starship/starship) :shell:
- **Terminal Emulator**: [kitty](https://sw.kovidgoyal.net/kitty/) :cat:
- **Panel**: [waybar](https://github.com/Alexays/Waybar) :shaved_ice:
- **Text Editor**: [neovim](https://neovim.io/) :keyboard:
- **App Launcher**: [rofi](https://davatorium.github.io/rofi/) :rocket:
- **File Manager**: [yazi](https://yazi-rs.github.io/) / [Thunar](https://github.com/neilbrown/thunar) :open_file_folder:
- **Browser**: [firefox](https://www.mozilla.org/) :globe_with_meridians:
- **Notification Manager**: [swaync](https://github.com/ErikReider/SwayNotificationCenter) :bell:
- **Colorscheme**: Mixed of Many colorscheme :art:

---

<details>
<summary><h3><i>
📸 Screenshots
</i></h3></summary>
<img src="assets/Rice.png">
<img src="assets/RofiLauncher.png">
<img src="assets/RofiEmoji.png">
<img src="assets/RofiNotes.png">
<img src="assets/RofiTmux.png">
<img src="assets/RofiWallpaper.png">
<img src="assets/RofiMusic.png">
<img src="assets/RofiMusicControl.png">
<img src="assets/ScreenRecorder.png">
<img src="assets/RofiPowermenu.png">
<img src="assets/Keybinds.png">
<img scr="assets/RofiTodoList.png">
<img scr="assets/QuickLink.png">
</details>

<h2> <b> HyprLand Setup </b> </h2>

<b> ArchInstall </b>
* Using ArchInstall Script Install Archlinux on bare metal.
* After Booting into HyprLand, Open terminal and install Aur Helper called Paru

<b> Install Paru (Aur Helper)</b>

```
git clone https://aur.archlinux.org/paru-bin.git
```
* cd paru-bin

* makepkg -Si

<h2> <b> Installing automatically </b> </h2>

```
curl https://raw.githubusercontent.com/S4NKALP/hyprland/main/Installer.sh -o $HOME/Installer
chmod +x Installer.sh
./Installer
```

<details>
<summary><h2>Manual Installation</h2></summary>

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
</details>

# Credits
I wanna point out some resources that helped me the most with the setup:

- [Matt](https://github.com/Matt-FTW/dotfiles) for README & nvim config.
- [JaKooLit](https://github.com/JaKooLit/HyprLand-Dots) for base configs as this is built on the base of his dotfiles
