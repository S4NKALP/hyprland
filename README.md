<div align="center">
	<a href="https://github.com/S4NKALP/hyprland/stargazers"><img alt="Stargazers" src="https://img.shields.io/github/stars/S4NKALP/hyprland?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41"></a>
	<a href="https://github.com/S4NKALP/hyprland/issues"><img alt="Forks" src="https://img.shields.io/github/issues/S4NKALP/hyprland?style=for-the-badge&logo=gitbook&color=B5E8E0&logoColor=D9E0EE&labelColor=302D41"></a>
  <a href="https://github.com/S4NKALP/hyprland/commits/main/"><img alt="Commit Activity" src="https://img.shields.io/github/commit-activity/m/S4NKALP/hyprland/main?style=for-the-badge&logo=github&color=F2CDCD&logoColor=D9E0EE&labelColor=302D41"/></a>
	<a href="https://github.com/S4NKALP/hyprland"><img alt="Size" src="https://img.shields.io/github/repo-size/S4NKALP/hyprland?style=for-the-badge&logo=discord&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41"></a>
</div>

# :herb: ‎ <samp>About</samp>

Hey there! :wave:

This is my personal dotfiles repository. A simple aesthetic (at least for me). I edited [JakooLit](https://github.com/JaKooLit/Hyprland-Dots) dotfiles for Hyprland for my base rice but without pywal.


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
- **Colorscheme**: [Dracula](https://github.com/dracula/dracula-theme) :art:

---

<details>
<summary><hb>
📸 Screenshots
</b></summary>
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

<details>
<summary><b> :package: Manual Installation </b></summary>
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

* At Last (Do this)
```
ln -sf "$HOME/.cache/wal/colors-rofi-dark.rasi" "$HOME/.config/rofi/pywal-color/pywal-theme.rasi"
```
</details>

# :tada: ‎ <samp>Credits</samp>

I wanna point out some resources that helped me the most with the setup:

- [Matt](https://github.com/Matt-FTW/dotfiles) for README & nvim config.
- [JaKooLit](https://github.com/JaKooLit/HyprLand-Dots) for base configs.

### :two_hearts: Star History and Contributors

Thanks to everyone who have contributed and given an star to this project!

<div align="center">

#### :pencil2: Contributors

</div>

<a href="https://github.com/S4NKALP/hyprland/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=S4NKALP/hyprland"/>
</a>

<div align="center">

#### :star: Star History

</div>

<div>
  <a href="https://star-history.com/#S4NKALP/hyprlands&Timeline">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=S4NKALP/hyprland&type=Timeline&theme=dark" />
      <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=S4NKALP/hyprland&type=Timeline" />
      <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=S4NKALP/hyprland&type=Timeline" />
    </picture>
  </a>
</div>
