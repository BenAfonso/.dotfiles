local M = {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  opts = function()
    vim.cmd([[:hi DashboardHeader guifg=#ff007f]])
    local logo = [[
██████╗ ███████╗███╗   ██╗    ██╗   ██╗██╗███╗   ███╗
██╔══██╗██╔════╝████╗  ██║    ██║   ██║██║████╗ ████║
██████╔╝█████╗  ██╔██╗ ██║    ██║   ██║██║██╔████╔██║
██╔══██╗██╔══╝  ██║╚██╗██║    ╚██╗ ██╔╝██║██║╚██╔╝██║
██████╔╝███████╗██║ ╚████║     ╚████╔╝ ██║██║ ╚═╝ ██║
╚═════╝ ╚══════╝╚═╝  ╚═══╝      ╚═══╝  ╚═╝╚═╝     ╚═╝
  .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.
 / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / 
`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'  
      ]]

    logo = string.rep("\n", 3) .. logo .. "\n\n"

    local opts = {
      theme = "doom",
      hide = {
        -- this is taken care of by lualine
        -- enabling this messes up the actual laststatus setting after loading a file
        statusline = false,
      },
      config = {
        header = vim.split(logo, "\n"),
        -- stylua: ignore
        center = {
          -- { action = "Telescope find_files",                                     desc = " Find file",       icon = " ", key = "f" },
          -- { action = "ene | startinsert",                                        desc = " New file",        icon = " ", key = "n" },
          { action = "Telescope oldfiles",                                       desc = " Recent files",    icon = " ", key = "h" },
          -- { action = "Telescope oldfiles",                                       desc = " Recent files",    icon = " ", key = "r" },
          -- { action = "Telescope live_grep",                                      desc = " Find text",       icon = " ", key = "g" },
          -- { action = [[lua require("lazyvim.util").telescope.config_files()()]], desc = " Config",          icon = " ", key = "c" },
          -- { action = 'lua require("persistence").load()',                        desc = " Restore Session", icon = " ", key = "s" },
          -- { action = "LazyExtras",                                               desc = " Lazy Extras",     icon = " ", key = "x" },
          { action = "Lazy",                                                     desc = " Lazy",            icon = "󰒲 ", key = "l" },
          { action = "qa",                                                       desc = " Quit",            icon = " ", key = "q" },
        },
        footer = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          return { "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms" }
        end,
      },
    }

    if require("ben.is-git-repositiory")() then
      table.insert(opts.config.center, {
        action = "Git",
        desc = " Git",
        icon = "  ",
        key = "l",
      })
    end

    for _, button in ipairs(opts.config.center) do
      button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
      button.key_format = "  %s"
    end

    -- close Lazy and re-open when the dashboard is ready
    if vim.o.filetype == "lazy" then
      vim.cmd.close()
      vim.api.nvim_create_autocmd("User", {
        pattern = "DashboardLoaded",
        callback = function()
          require("lazy").show()
        end,
      })
    end

    return opts
  end,
}

return M
