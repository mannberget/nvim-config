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
