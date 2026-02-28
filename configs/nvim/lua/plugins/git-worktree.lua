return {
  "ThePrimeagen/git-worktree.nvim",
  opts = {
    change_directory_command = "tcd"
  },
  config = function(_, opts)
    require("git-worktree").setup(opts)
    require("telescope").load_extension("git_worktree")


    vim.keymap.set("n", "<leader>sW", function()
      require('telescope').extensions.git_worktree.git_worktrees()
    end)
    vim.keymap.set("n", "<leader>hw", function()
      require('telescope').extensions.git_worktree.git_worktrees()
    end)
  end,
}
