local lspkind_comparator = function(conf)
  local lsp_types = require("cmp.types").lsp
  return function(entry1, entry2)
    if entry1.source.name ~= "nvim_lsp" then
      if entry2.source.name == "nvim_lsp" then
        return false
      else
        return nil
      end
    end
    local kind1 = lsp_types.CompletionItemKind[entry1:get_kind()]
    local kind2 = lsp_types.CompletionItemKind[entry2:get_kind()]

    local priority1 = conf.kind_priority[kind1] or 0
    local priority2 = conf.kind_priority[kind2] or 0
    if priority1 == priority2 then
      return nil
    end
    return priority2 < priority1
  end
end

local label_comparator = function(entry1, entry2)
  return entry1.completion_item.label < entry2.completion_item.label
end

return {
  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    -- event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      -- "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-calc",
      "hrsh7th/cmp-emoji",
      "folke/lazydev.nvim",
    },
    opts = function(_, opts)
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      return {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- performance = {
        --   max_view_entries = 7,
        -- },
        mapping = cmp.mapping.preset.insert({
          ["<C-u>"] = cmp.mapping.scroll_docs(-4), -- Scroll up
          ["<C-d>"] = cmp.mapping.scroll_docs(4), -- Scroll down
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<C-j>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item() -- ({ behaviour = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s", "c" }),
          ["<C-k>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s", "c" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item() -- ({ behaviour = cmp.SelectBehavior.Select })
            elseif luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
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
          {
            name = "nvim_lsp",
            priority = 1200,
            -- max_item_count = 20,
            entry_filter = function(entry, ctx)
              local kind = entry:get_kind()

              if kind == "Text" then
                return false
              end
              return true
            end,
          },
          { name = "luasnip", priority = 1000, max_item_count = 5 },
          { name = "nvim_lua", priority = 100, max_item_count = 20 },
          { name = "lazydev", group_index = 0, max_item_count = 20 },
          { name = "copilot", priority = 800 },
          { name = "vim-dadbod-completion", priority = 700 }, -- add new source
        }, {
          { name = "buffer", priority = 500, keyword_length = 3, max_item_count = 10 },
          { name = "emoji", priority = 800, max_item_count = 100 },
          { name = "path", priority = 250, max_item_count = 3 },
          { name = "calc" },
        }),
        -- sorting = {
        --   comparators = {
        --     cmp.config.compare.offset,
        --     cmp.config.compare.kind,
        --     cmp.config.compare.exact,
        --     cmp.config.compare.score,
        -- lspkind_comparator({
        --   kind_priority = {
        --     Field = 11,
        --     Property = 11,
        --     Constant = 10,
        --     Enum = 10,
        --     EnumMember = 10,
        --     Event = 10,
        --     Function = 10,
        --     Method = 10,
        --     Operator = 10,
        --     Reference = 10,
        --     Struct = 10,
        --     Variable = 9,
        --     File = 8,
        --     Folder = 8,
        --     Class = 5,
        --     Color = 5,
        --     Module = 5,
        --     Keyword = 2,
        --     Constructor = 1,
        --     Interface = 1,
        --     Snippet = 0,
        --     Text = 1,
        --     TypeParameter = 1,
        --     Unit = 1,
        --     Value = 1,
        --   },
        -- }),
        -- label_comparator,

        --   cmp.config.compare.sort_text,
        --   cmp.config.compare.length,
        --   cmp.config.compare.order,
        -- },
        -- },
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
              vim_item.kind = (cmp_kind or "") .. " " .. (vim_item.kind or "")
            end
            return vim_item
          end,
        },
      }
    end,
    config = function(_, opts)
      local cmp = require("cmp")
      --   local luasnip = require("luasnip")
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
      --
      cmp.setup(opts)
      --
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
}
