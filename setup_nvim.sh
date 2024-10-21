#!/bin/bash

# List of URLs to clone
urls=(
    "https://github.com/nvim-treesitter/nvim-treesitter"
    "https://github.com/neovim/nvim-lspconfig"
    "https://github.com/hrsh7th/nvim-cmp"
    "https://github.com/hrsh7th/cmp-nvim-lsp"
    "https://github.com/hrsh7th/cmp-path"
)

# Define the target directory for cloning
target_dir="pack/nvim/start"

# Create the target directory if it doesn't exist
mkdir -p "$target_dir"

# Loop through the URLs and clone each repository
for url in "${urls[@]}"; do
    # Extract the repository name from the URL
    repo_name=$(basename "$url")
    
    # Check if the repository already exists
    if [ ! -d "$target_dir/$repo_name" ]; then
        echo "Cloning $url into $target_dir/$repo_name"
        git clone "$url" "$target_dir/$repo_name"
    else
        echo "$target_dir/$repo_name already exists, skipping clone."
    fi
done

# Create a symlink from ~/.config/nvim to the script's root directory
nvim_config_dir=$(pwd)

# Check if ~/.config/nvim exists or is a symlink
if [ -L "$HOME/.config/nvim" ] || [ -d "$HOME/.config/nvim" ]; then
    echo "A symlink or directory already exists at ~/.config/nvim."
    echo "Please manually remove it before running this script again."
    exit 1
fi

echo "Creating symlink from $nvim_config_dir to ~/.config/nvim"
ln -s "$nvim_config_dir" "$HOME/.config/nvim"

echo "Setup complete!"
