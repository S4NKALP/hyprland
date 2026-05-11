#!/bin/bash

# This script sets up the dotfiles by symlinking the config folders 
# and sourcing the zsh configuration.

# Get the absolute path of the project directory
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_SRC_DIR="$PROJECT_DIR/config"
ZSHRC_SRC="$PROJECT_DIR/misc/.zshrc"

# Target directory for configs
CONFIG_DEST_DIR="$HOME/.config"

# Create ~/.config if it doesn't exist
mkdir -p "$CONFIG_DEST_DIR"

echo "Step 1: Symlinking configuration folders to $CONFIG_DEST_DIR..."

# Loop through all folders and files in the project's config directory
for item in "$CONFIG_SRC_DIR"/*; do
    if [ -e "$item" ]; then
        name=$(basename "$item")
        
        # Skip the 'archive' directory
        if [ "$name" == "archive" ]; then
            continue
        fi

        target="$CONFIG_DEST_DIR/$name"
        
        # Check if target exists and is not a symlink
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  [WARN] $name already exists as a real directory/file. Backing up to ${name}.bak"
            mv "$target" "${target}.bak"
        fi

        # -s: symbolic link
        # -n: treat destination that is a symlink to a directory as a normal file
        # -f: force (remove existing destination)
        ln -snf "$item" "$target"
        echo "  [OK] Linked $name"
    fi
done

echo "Step 2: Symlinking misc/.zshrc to $HOME/.zshrc..."

ZSHRC_DEST="$HOME/.zshrc"

# Check if target exists and is not a symlink
if [ -e "$ZSHRC_DEST" ] && [ ! -L "$ZSHRC_DEST" ]; then
    echo "  [WARN] .zshrc already exists. Backing up to .zshrc.bak"
    mv "$ZSHRC_DEST" "${ZSHRC_DEST}.bak"
fi

ln -snf "$ZSHRC_SRC" "$ZSHRC_DEST"
echo "  [OK] Linked .zshrc"

echo "Step 3: Symlinking scripts from misc/bin to $HOME/.local/bin..."

BIN_SRC_DIR="$PROJECT_DIR/misc/bin"
BIN_DEST_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DEST_DIR"

for item in "$BIN_SRC_DIR"/*; do
    if [ -e "$item" ]; then
        name=$(basename "$item")
        target="$BIN_DEST_DIR/$name"
        
        # Check if target exists and is not a symlink
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  [WARN] $name already exists in ~/.local/bin. Backing up to ${name}.bak"
            mv "$target" "${target}.bak"
        fi

        # Ensure the script is executable
        chmod +x "$item"

        ln -snf "$item" "$target"
        echo "  [OK] Linked $name"
    fi
done

echo ""
echo "All done! Please restart your terminal or run 'source ~/.zshrc'."
