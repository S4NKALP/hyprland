<div align = "center">

<h1><a href="https://github.com/S4NKALP/hyprland">Hyprland</a></h1>

<div align="center"><p>
<img alt="Commit Activity" src="https://img.shields.io/github/commit-activity/m/S4NKALP/hyprland?style=for-the-badge&logo=instatus&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41" />
<img alt="Last Commit" src="https://img.shields.io/github/last-commit/S4NKALP/hyprland?style=for-the-badge&logo=instatus&color=ee999f&logoColor=D9E0EE&labelColor=302D41" />
<img src="https://img.shields.io/github/license/S4NKALP/hyprland?style=for-the-badge&logo=instatus&color=c69ff5&logoColor=D9E0EE&labelColor=302D41" alt="GitHub License"><br>
<img src="https://img.shields.io/github/watchers/S4NKALP/hyprland?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=D9E0EE&labelColor=302D41" alt="Codecov coverage">
<img src="https://img.shields.io/github/repo-size/S4NKALP/hyprland?color=%23DDB6F2&label=SIZE&logo=instatus&style=for-the-badge&logoColor=D9E0EE&labelColor=302D41" alt="GitHub code size">
</div>

<p align="center">
  <strong>Dotfiles</strong>
  <br>
    A dotfiles setup for Hyprland. Personal but easy to set up.
        <br>
    Not recommended for existing configurations.
<br>

  <a href="https://github.com/S4NKALP/hyprland/">[Document]</a>
  ·
  <a href="https://github.com/S4NKALP/hyprland/issues">[Report a bug]</a>
  ·
  <a href="https://github.com/S4NKALP/hyprland/issues">[Suggesting new features.]</a>
</p>

<br>

<table align="center">
   <tr>
      <th align="center">
         <sup><sub>:warning: WARNING :warning:</sub></sup>
      </th>
   </tr>
   <tr>
      <td align="center">

    Designed for Arch Linux. Compatibility with other systems is not guaranteed.
    VMs are not supported.
    NVIDIA GPU not supported

   </tr>
   </table>

<h3>Hyprland Dots As I use for my daily driver<h3>


<figure>
  <img src="assets/Rice.png" alt="hyprland" width="300">
  <img src="assets/Rice 1.png" alt="rice" width="300">
  <img src="assets/Rice 2.png" alt="rice" width="300">
  <img src="assets/Rice 3.png" alt="rice" width="300">
  <img src="assets/Rice 4.png" alt="rice" width="300">
  <br/>
</figure>


</div>

## 🌌 Overview

<h4>This repository contains Arch Linux's DotFiles, which I use on a daily basis. <br>
It includes custom settings, aliases, settings for familiar tools, and more to quickly create my ideal work environment on any machine.</h4>
<hr>

### 🌸 Core System Info

- **OS**: [Arch Linux](https://archlinux.org/) :boom:
- **WM**: [hyprland](https://hyprland.org/) :window:
- **Shell**: [zsh](https://www.zsh.org/) / [starship](https://github.com/starship/starship) :shell:
- **Terminal Emulator**: [kitty](https://sw.kovidgoyal.net/kitty/) :cat:
- **Panel**: [AGS](https://aylur.github.io/ags-docs/) :shaved_ice:
- **Text Editor**: [neovim](https://neovim.io/) / [geany](https://www.geany.org/) :keyboard:
- **App Launcher**: [AGS](https://aylur.github.io/ags-docs/) :rocket:
- **File Manager**: [yazi](https://yazi-rs.github.io/) / [Thunar](https://github.com/neilbrown/thunar) :open_file_folder:
- **Browser**: [firefox](https://www.mozilla.org/) :globe_with_meridians:
- **Colorscheme**: [adw](https://github.com/lassekongo83/adw-gtk3) :art:

---

## Composition

```

  Dotfiles🌴
    │
    ├─ 📁 assets
    │   └─ screenshot fonts
    ├─ 📁 config
    │   └─ configuration directory
    ├─ 📁 misc
    │   └─ bins/scripts
    ├─ 📁 wallpapers
        └─ wallpapers used for hyprland


```
```

Setup script execution flow:
  1. **Environment confirmation**:
      - Ask user for confirmation before starting script
      - Perform a system check
      - Check your internet connection
      - Check git installation
      - Check the VM environment
      - Check NVIDIA usage

  2. **AUR installation**:
      - Installing paru (AUR helper)

  3. **Software installation**:
      - Show package installation steps
      - Display installation results for each package

  4. **Copy settings**:
      - copy zsh dotfiles
      - Copy other config files

  5. **Enabling the service**:
      - Start Bluetooth service
      - Enabling SDDM service
      - Start powerprofile daemon

  6. **Theme settings**:
      - Set GTK and icon themes
      - Fixed configuration file to enable theme

  7. **Change Shell**:
      - Change default shell to Zsh

  8. **File permission settings**:
      - Give execution permission to some script files

  9. **Other settings**:
      - Perform non-critical actions such as creating necessary directories
      - Synchronize dotfiles

```

### ✨ Features

- :dark_sunglasses: Dark Mode for the Whole System
- :bell: Notification Center
- :framed_picture: Various Wallpapers
- :nerd_face: Nerd Fonts for the Shell Prompt
- :iphone: App Launcher
- :keyboard: Multiple Keyboard Layouts
- :car: Automatic mount of USB devices with notification
- :lock: Idle and lock apps
- :open_file_folder: Following XDG Base Directory Standard
- :broom: Organized and cleaned up config files
- :point_up: Screenshot, Clipboard and Wallpaper Picker
- :boom: Performance Mode
- :gear: Various other tweaks & scripts
- :art: Autogenerated Colors
- :window: Fluid Animations
- :sparkles: Ripple Effects


## :keyboard: Keyboard Shortcuts Guide

```
    Windows + Enter: Open Terminal
    Windows + E: Thunar File Manager
    Windows + D: Application Launcher
    Windows + C: Close Program
    Windows + W: Wallpaper Picker
    Windows + Space: Change Screen Layout Style
    PrtSc: Taking Screentshot
    Windows + F3: Change Keyboard Layout
    Windows + Slash: For Keybinds

Other keybinds can be found in ~/dotfiles/hypr/UserConfigs/UserKeybinds.conf
or in ~/dotfiles/hypr/configs/Keybinds.conf

```


# :wrench: ‎ <samp>Setup</samp>

<b> ArchInstall </b>
* Using ArchInstall Script Install Archlinux on bare metal.
* After Booting into HyprLand, Open terminal and install Aur Helper called Paru
### :package: <samp>Automatic Installation (Arch Linux)</samp>

<figure>
    <img src ="assets/installer.png" alt="installer"
    width="800">
</figure>

```
git clone -b AGS https://github.com/S4NKALP/hyprland.git
cd hyprland
chmod +x setup
./setup
```

### 🧰 Tools Used

- I got a lot of code for AGS from [koeqaife](https://github.com/koeqaife)
- [nvim](https://github.com/S4NKALP/nvim) — Personalized Editor
- [blog](https://github.com/S4NKALP/blog) — Blog
<hr>

<div align="center">

<strong>⭐ hit the star button if you found this useful ⭐</strong><br>

</div>
If you have any questions, issues, or suggestions, feel free to let us know by opening an issue. Your feedback is greatly appreciated!

<div align ="center">
    <strong>Thank you for your support as well🦊</strong>
</div>
