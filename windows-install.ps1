# PowerShell script to clone Neovim plugins

# Plugins URLs
$urls = @(
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/hrsh7th/nvim-cmp",
    "https://github.com/hrsh7th/cmp-nvim-lsp",
    "https://github.com/hrsh7th/cmp-path",
    "https://github.com/hrsh7th/cmp-nvim-lsp-signature-help",
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/folke/ts-comments.nvim"
)

# Define the target directory for cloning
$targetDir = "pack/nvim/start"

# Create the target directory if it doesn't exist
if (-not (Test-Path -Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir
}

# Loop through the URLs and clone each repository
foreach ($url in $urls) {
    # Extract the repository name from the URL
    $repoName = [System.IO.Path]::GetFileName($url)

    # Check if the repository already exists
    if (-not (Test-Path -Path "$targetDir\$repoName")) {
        Write-Host "Cloning $url into $targetDir\$repoName"
        git clone $url "$targetDir\$repoName"
    } else {
        Write-Host "$targetDir\$repoName already exists, skipping clone."
    }
}

