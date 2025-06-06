local M = {
  "stevearc/conform.nvim",
  opts = {},
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      notify_on_error = false,
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "prefer",
      },
      format_after_save = {
        lsp_format = "prefer",
      },
      formatters_by_ft = {
        lua = { "stylua" },
        go = { "gofmt" },
        -- Use a sub-list to run only the first available formatter
        ["javascript"] = { "prettier" },
        ["javascriptreact"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["typescriptreact"] = { "prettier" },
        ["astro"] = { "prettier" },
        ["vue"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["json"] = { "prettier" },
        ["jsonc"] = { "prettier" },
        ["yaml"] = { "prettier" },
        ["markdown"] = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        ["graphql"] = { "prettier" },
        ["handlebars"] = { "prettier" },
      },
    })

    vim.api.nvim_create_user_command("Format", function()
      require("conform").format()
    end, {})

    vim.keymap.set("n", "<leader>cf", function()
      require("conform").format()
    end)

    -- vim.api.nvim_create_autocmd("BufWritePre", {
    --   pattern = "*",
    --   group = vim.api.nvim_create_augroup("conform-autosave", { clear = true }),
    --   callback = function(args)
    --     require("conform").format({ bufnr = args.buf })
    --   end,
    -- })
  end,
}

return M
