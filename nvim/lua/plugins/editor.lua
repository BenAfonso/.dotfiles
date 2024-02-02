return {
  {
    "akinsho/toggleterm.nvim",
  },
  {
    "ThePrimeagen/vim-be-good",
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true },
  {
    -- <leader>F5
    "mbbill/undotree",
  },
  {
    "tpope/vim-fugitive",
  },
  {
    enabled = false,
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function(_, opts)
      vim.cmd([[:hi DashboardHeader guifg=#ff007f]])
      local logo = [[
        ██████╗ ███████╗███╗   ██╗    ██╗   ██╗██╗███╗   ███╗
        ██╔══██╗██╔════╝████╗  ██║    ██║   ██║██║████╗ ████║
        ██████╔╝█████╗  ██╔██╗ ██║    ██║   ██║██║██╔████╔██║
        ██╔══██╗██╔══╝  ██║╚██╗██║    ╚██╗ ██╔╝██║██║╚██╔╝██║
        ██████╔╝███████╗██║ ╚████║     ╚████╔╝ ██║██║ ╚═╝ ██║
        ╚═════╝ ╚══════╝╚═╝  ╚═══╝      ╚═══╝  ╚═╝╚═╝     ╚═╝
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"
      opts.config.header = vim.split(logo, "\n")
    end,
  },
}
