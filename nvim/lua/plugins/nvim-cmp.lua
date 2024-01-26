---@diagnostic disable: no-unknown, undefined-global
local M = {
  "nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-calc",
    "zbirenbaum/copilot-cmp",
    "saadparwaiz1/cmp_luasnip",
    "L3MON4D3/LuaSnip",
    "hrsh7th/cmp-emoji",
  },
}

M.config = function()
  local cmp = require("cmp")
  local luasnip = require("luasnip")
  vim.opt.completeopt = { "menu", "menuone", "noselect" }

  -- Highlights
  -- gray
  vim.api.nvim_set_hl(0, "CmpItemAbbrDeprecated", { bg = "NONE", strikethrough = true, fg = "#808080" })
  -- blue
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", { bg = "NONE", fg = "#569CD6" })
  vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", { link = "CmpIntemAbbrMatch" })
  -- light blue
  vim.api.nvim_set_hl(0, "CmpItemKindVariable", { bg = "NONE", fg = "#9CDCFE" })
  vim.api.nvim_set_hl(0, "CmpItemKindInterface", { link = "CmpItemKindVariable" })
  vim.api.nvim_set_hl(0, "CmpItemKindText", { link = "CmpItemKindVariable" })
  -- pink
  vim.api.nvim_set_hl(0, "CmpItemKindFunction", { bg = "NONE", fg = "#C586C0" })
  vim.api.nvim_set_hl(0, "CmpItemKindMethod", { link = "CmpItemKindFunction" })
  -- front
  vim.api.nvim_set_hl(0, "CmpItemKindKeyword", { bg = "NONE", fg = "#D4D4D4" })
  vim.api.nvim_set_hl(0, "CmpItemKindProperty", { link = "CmpItemKindKeyword" })
  vim.api.nvim_set_hl(0, "CmpItemKindUnit", { link = "CmpItemKindKeyword" })

  vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })

  cmp.setup({
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<C-j>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item() -- ({ behaviour = cmp.SelectBehavior.Select })
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<C-k>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    sources = cmp.config.sources({
      -- { name = "copilot", priority = 800 },
      { name = "nvim_lsp", priority = 1000 },
      { name = "luasnip", priority = 750 },
      { name = "emoji", priority = 1000 },
      { name = "buffer", priority = 500 },
      { name = "path", priority = 250 },
      { name = "calc" },
      -- { name = "vim-dadbod-completion", priority = 700 }, -- add new source
    }, {
      { name = "buffer" },
      { name = "path" },
    }),
    formatting = {
      fields = { "menu", "abbr", "kind" },
      format = function(entry, vim_item)
        local custom_menu_icon = {
          calc = "󰃬",
        }
        if entry.source.name == "calc" then
          vim_item.menu = custom_menu_icon.calc
          vim_item.kind = ""
        else
          local cmp_kind = require("utils.lsp_icons")[vim_item.kind]
          vim_item.menu = cmp_kind or ""
          vim_item.kind = cmp_kind .. " " .. vim_item.kind
        end
        return vim_item
      end,
    },
    -- formatting = {
    --   fields = { "abbr", "kind", "menu" },
    --   format = function(entry, vim_item)
    --     -- Kind icons
    --     vim_item.kind = string.format("%s %s", require("utils.lsp_icons")[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
    --     return vim_item
    --     2 + 100
    --     2 + 3
    --   end,
    -- },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })
end

return M
