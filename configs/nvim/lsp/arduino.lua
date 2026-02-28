---@type vim.lsp.Config
return {
    filetypes = { 'arduino', 'cpp' },
    root_markers = { "sketch.yaml" },
    -- root_dir = function(_, on_dir)
    --     on_dir(vim.fn.expand("%:p:h"))
    -- end,
    cmd = {
        'arduino-language-server',
        -- "-fqbn", "esp32:esp32:esp32c6",
    },
    capabilities = {
        textDocument = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            semanticTokens = vim.NIL,
        },
        workspace = {
            ---@diagnostic disable-next-line: assign-type-mismatch
            semanticTokens = vim.NIL,
        },
    },
}
