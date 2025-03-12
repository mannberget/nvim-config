#!/bin/bash

# Base URL for GitHub repositories
base_url="https://github.com/"

# Plugin repositories with corresponding tags (repo, tag)
repos_and_tags=(
    "nvim-treesitter/nvim-treesitter" "default"
    "neovim/nvim-lspconfig" "default"
    "hrsh7th/nvim-cmp" "default"
    "hrsh7th/cmp-nvim-lsp" "default"
    "hrsh7th/cmp-path" "default"
    "hrsh7th/cmp-nvim-lsp-signature-help" "default"
    "nvim-lua/plenary.nvim" "default"
    "nvim-telescope/telescope.nvim" "0.1.8"
    "stevearc/oil.nvim" "default"
    "folke/ts-comments.nvim" "default"
    "nvimtools/none-ls.nvim" "default"
    "github/copilot.vim" "default"
)

# Define the target directory for cloning
target_dir="pack/nvim/start"

# Create the target directory if it doesn't exist
mkdir -p "$target_dir"

# Loop through the repository names and corresponding tags
for ((i=0; i<${#repos_and_tags[@]}; i+=2)); do
    repo="${repos_and_tags[$i]}"
    tag="${repos_and_tags[$i+1]}"
    
    # Extract the repository name from the URL
    repo_name=$(basename "$repo")
    
    # Check if the repository already exists
    if [ ! -d "$target_dir/$repo_name" ]; then
        # Construct the full clone URL
        url="${base_url}${repo}"
        
        if [ "$tag" == "default" ]; then
            echo "Cloning $url using the default branch into $target_dir/$repo_name"
            git clone "$url" "$target_dir/$repo_name"
        else
            echo "Cloning $url with tag/branch $tag into $target_dir/$repo_name"
            git clone --branch "$tag" "$url" "$target_dir/$repo_name"
        fi
    else
        echo "$target_dir/$repo_name already exists, skipping clone."
    fi
done

