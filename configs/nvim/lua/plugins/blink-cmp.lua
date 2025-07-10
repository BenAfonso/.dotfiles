local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local M = {
  'saghen/blink.cmp',
  enabled = true,
  -- optional: provides snippets for the snippet source
  dependencies = 'rafamadriz/friendly-snippets',

  -- use a release tag to download pre-built binaries
  version = '*',
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept, C-n/C-p for up/down)
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys for up/down)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-e: Hide menu
    -- C-k: Toggle signature help
    --
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = {
      preset = "default",
      ["<C-k>"] = { 'select_prev', 'fallback' },
      ["<C-j>"] = { 'select_next', 'fallback' },
      ["<Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          elseif has_words_before() and cmp.is_visible() then
            return cmp.select_next()
          else
          end
        end,
        'snippet_forward',
        'fallback'
      },
      ["<S-Tab>"] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          elseif has_words_before() and cmp.is_visible() then
            return cmp.select_prev()
          else
          end
        end,
        'snippet_backward',
        'fallback'
      },
      ["<Enter>"] = { 'select_and_accept', 'fallback' },
    },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = 'mono'
    },

    completion = {
      accept = {
        auto_brackets = {
          enabled = false
        },
      },
      trigger = {
        show_in_snippet = false,
        show_on_keyword = true,
        show_on_trigger_character = true,
        show_on_x_blocked_trigger_characters = { "'", '"', '(', '{', '[', '\t', '	' },
        show_on_blocked_trigger_characters = { ' ', '\n', '\t', '	' },
      },
      list = {
        selection = {
          auto_insert = true,
          preselect = function(ctx)
            return not require('blink.cmp').snippet_active({ direction = 1 })
          end,
        }
      },
      ghost_text = {
        enabled = false,
        show_with_menu = false
      },
      menu = {
        border = "single",
        draw = {
          components = {
            kind_icon = {
              ellipsis = false,
              text = function(ctx)
                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                return kind_icon
              end,
              -- Optionally, you may also use the highlights from mini.icons
              highlight = function(ctx)
                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                return hl
              end,
            }
          },
          columns = {
            { "label",     "label_description", gap = 1 },
            { "kind_icon", "kind",              gap = 1 },
          }
        }
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
        window = {
          border = "single"
        }
      }
    },
    signature = {
      window = { border = 'single' }
    },

    cmdline = {
      keymap = {
        preset = "default",
        ["<C-k>"] = { 'select_prev', 'fallback' },
        ["<C-j>"] = { 'select_next', 'fallback' },
        ["<Tab>"] = {
          'select_and_accept',
          'fallback'
        },
        -- ["<Enter>"] = { 'select_and_accept', 'fallback' },
      },

      completion = {
        menu = {
          auto_show = function(ctx)
            return vim.fn.getcmdtype() == ':'
            -- enable for inputs as well, with:
            -- or vim.fn.getcmdtype() == '@'
          end,
        },
      },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = {
          name = "LazyDev",
          fallbacks = { 'lsp' },
          module = "lazydev.integrations.blink",
          score_offset = 100,
        }
      }
    },

    -- Blink.cmp uses a Rust fuzzy matcher by default for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" }
  },
  opts_extend = { "sources.default" }
}

return M
