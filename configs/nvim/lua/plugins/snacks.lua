local M = {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    win = {
      backdrop = {
        blend = 80
      }
    },
    -- animate = { enabled = false },
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
██████╗ ███████╗███╗   ██╗ ██╗   ██╗██╗███╗   ███╗
██╔══██╗██╔════╝████╗  ██║ ██║   ██║██║████╗ ████║
██████╔╝█████╗  ██╔██╗ ██║ ██║   ██║██║██╔████╔██║
██╔══██╗██╔══╝  ██║╚██╗██║ ╚██╗ ██╔╝██║██║╚██╔╝██║
██████╔╝███████╗██║ ╚████║  ╚████╔╝ ██║██║ ╚═╝ ██║
╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
  .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.
 / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / /
`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
        ]]
      },
      sections = {
        { section = "header", hl = "Dashboard", padding = 3 },
        {
          text = {
            {
              "I use nvim, btw.",
              hl = "Dashboard",
              align = "center",
            },
          },
        },
        -- { section = "keys" },
        {
          padding = { 0, 10 },
          section = "startup",
          hl = "Dashboard",
        },
      }
    },
    explorer = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      matcher = {
        frecency = true
      },
      debug = {
        -- scores = true
      },
      hidden = false,
      unloaded = true,
      current = true,

    },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    lazygit = {
      enabled = false
      -- configure = true,
      -- -- extra configuration for lazygit that will be merged with the default
      -- -- snacks does NOT have a full yaml parser, so if you need `"test"` to appear with the quotes
      -- -- you need to double quote it: `"\"test\""`
      -- config = {
      --   os = { editPreset = "nvim-remote" },
      --   gui = {
      --     -- set to an empty string "" to disable icons
      --     nerdFontsVersion = "3",
      --   },
      -- },
    },
    styles = {
      notification = {
        -- wo = { wrap = true } -- Wrap notifications
      }
    }
  },
  keys = {
    -- Top Pickers & Explorer
    {
      "<leader>gl",
      function()
        Snacks.picker.git_log({
          on_show = function()
            vim.cmd.stopinsert()
          end,
          finder = "git_log",
          format = "git_log",
          preview = "git_show",
          confirm = "git_checkout",
          layout = "vertical",
        })
      end,
      desc = "[G]it Log",
    },
    {
      "<leader><space>",
      function()
        Snacks.picker.smart({
          layout = 'ivy'
        })
      end,
      desc = "Smart Find Files"
    },
    {
      "<leader>go",
      function() Snacks.lazygit() end,
      desc = "Open Lazygit"
    },
    {
      "<C-p>",
      function()
        Snacks.picker.files({
          hidden = true
        })
      end,
      desc = "[S]earch [F]iles"
    },
    {
      "<leader>sh",
      function()
        Snacks.picker.help({
          win = {
            input = {
              keys = {
                ["sv"] = { "edit_vsplit", mode = { "n" } },
                ["te"] = { "tab", mode = { "n" } },
                ["<CR>"] = { "edit_vsplit", mode = { "n", "i" } }
              }
            },
          }
        })
      end,
      desc = "[S]earch [H]elp"
    },
    {
      "<leader>sk",
      function()
        Snacks.picker.keymaps({
          layout = "vertical"
        })
      end,
      desc = "[S]earch [K]eymaps"
    },
    { "<leader>sw", function() Snacks.picker.grep_word() end,     desc = "[S]earch current [W]ord" },
    { "<leader>sP", function() Snacks.picker.pickers() end,       desc = "[S]earch [P]ickers" },
    { "<leader>sb", function() Snacks.picker.grep_buffers() end,  desc = "[S]earch current [B]uffer" },
    { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "[S]earch [T]odos" },
    { "<leader>sC", function() Snacks.picker.colorschemes() end,  desc = "[S]earch [T]heme" },
    { "<leader>sH", function() Snacks.picker.highlights() end,    desc = "[S]earch [H]ighlights" },
    { ";r",         function() Snacks.picker.grep() end,          desc = "[S]earch by [G]rep" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end,   desc = "[S]earch [D]iagnostics" },
    { ";;",         function() Snacks.picker.resume() end,        desc = "[S]earch [R]esume" },
    { "<leader>s.", function() end,                               desc = '[S]earch Recent Files ("." for repeat)' },
    { "<leader>os", function() Snacks.scratch() end,              desc = '[O]pen [s]cratch buffer' },
    { "<leader>oS", function() Snacks.scratch.select() end,       desc = '[O]pen [S]cratch buffer selector' },
    {
      "<leader>hh",
      function()
        Snacks.picker.lines({
          buf = vim.api.nvim_get_current_buf(),
          layout = {
            height = 0.2,
            preset = "dropdown",
            preview = false
          }
        })
      end,
      desc = '[O]pen [S]cratch buffer selector'
    },
    {
      "\\\\",
      function()
        Snacks.picker.buffers({
          finder = "buffers",
          format = "buffer",
          layout = "ivy",
          hidden = false,
          current = true,
          sort_lastused = true,
          on_show = function()
            vim.cmd.stopinsert()
          end,
          win = {
            input = { keys = { ["d"] = "bufdelete" } },
            list = { keys = { ["d"] = "bufdelete" } }
          }
        })
      end,
      desc = "Find existing buffers"
    },
  },
  config = function(_, opts)
    require('snacks').setup(opts)
  end

}

return M
