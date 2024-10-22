#!/bin/bash

# Plugins
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
