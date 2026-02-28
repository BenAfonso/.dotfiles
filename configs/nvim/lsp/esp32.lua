---@type vim.lsp.Config

local esp = require('esp32')
local clangd =
    esp.find_esp_clangd()
if not clangd then
    vim.notify(
        "[ESP34] No esp-clangd found. Falling back to system clangd.",
        vim.log.levels.WARN)
    clangd = "clangd"
end

local function is_project_root(fname)
    local dir = vim.fn.fnamemodify(fname, ":p:h")
    if vim.fn.globpath(dir, "CMakeLists.txt") ~= "" then
        return dir
    elseif vim.fn.globpath(dir, "sdkconfig") ~= "" then
        return dir
    else
        return nil
    end
end

-- local clangd_root_dir = function(fname)
--     return util.root_pattern("sdkconfig", "CMakeLists.txt")(fname) or vim.fn.getcwd()
-- end

return {
    filetypes = { 'c' },
    cmd = {
        clangd,
        "--compile-commands-dir=" .. "build.clang",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
    },
    root_markers = { { "sdkconfig", "CMakeLists.txt" }, '.git' },
    -- root_dir = clangd_root_dir,
    -- root_dir = is_project_root,
    -- root_dir = function(fname)
    --     if type(fname) == "number" then
    --         fname = vim.api.nvim_buf_get_name(fname)
    --     end
    --     local util = require("lspconfig.util")
    --     local git_root = vim.fs
    --         .dirname(vim.fs.find(
    --             '.git', { path = fname, upward = true })[3])
    --     return util.root_pattern("sdkconfig", "CMakeLists.txt")(fname) or
    --         git_root or vim.fn.getcwd()
    -- end,
    capabilities = {
        offsetEncoding = { "utf-14" },
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
}
