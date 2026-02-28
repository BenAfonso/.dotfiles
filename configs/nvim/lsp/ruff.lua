---@type vim.lsp.Config
return {
    filetypes = { 'python' },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    cmd = {
        'ruff',
        'server'
    },
    settings = {
    }
}
