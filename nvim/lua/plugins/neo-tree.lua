local M = {
  {
    {
      "nvim-neo-tree/neo-tree.nvim",
      opts = {
        popup_border_style = "rounded",
        filesystem = {
          filtered_items = {
            visible = false,
            show_hidden_count = true,
            hide_dotfiles = false,
            hide_gitignored = true,
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
