local M = {
  {
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        sources = { "filesystem", "buffers", "git_status", "document_symbols" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
        popup_border_style = "rounded",
        window = {
          -- position = "float",
          mappings = {
            ["<space>"] = "none",
            ["Y"] = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              vim.fn.setreg("+", path, "c")
            end,
          },
        },
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
          default_component_configs = {
            indent = {
              with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
              expander_collapsed = "",
              expander_expanded = "",
              expander_highlight = "NeoTreeExpander",
            },
          },
          filtered_items = {
            visible = false,
            show_hidden_count = true,
            hide_dotfiles = false,
            hide_gitignored = true,
            follow_current_file = {
              enabled = true,
              leave_dirs_open = false,
            },
            always_show = {
              ".env",
            },
            hide_by_name = {
              ".git",
              ".DS_Store",
            },
            never_show = {},
          },
        },
      },
    },
  },
}

return M
