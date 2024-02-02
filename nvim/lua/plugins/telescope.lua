---@diagnostic disable: no-unknown
-- Telescope configuration
local map = vim.keymap.set
local telescope = require("telescope")
local telescope_builtin = require("telescope.builtin")

local M = {
  {
    "telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        version = "^1.0.0",
      },
    },
    keys = {
      {
        "<leader>fP",
        function()
          require("telescope.builtin").find_files({
            cwd = require("lazy.core.config").options.root,
          })
        end,
        desc = "Find Plugin File",
      },
      {
        ";f",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        "<C-p>",
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files({
            -- no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        ";c",
        function()
          local builtin = require("telescope.builtin")
          builtin.keymaps({})
        end,
        desc = "Lists all keymaps",
      },
      {
        ";r",
        function()
          require("telescope").extensions.live_grep_args.live_grep_args()
        end,
        desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
      },
      {
        "\\\\",
        function()
          local builtin = require("telescope.builtin")
          builtin.buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";h",
        function()
          local builtin = require("telescope.builtin")
          builtin.help_tags()
        end,
        desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
      },
      {
        ";;",
        function()
          local builtin = require("telescope.builtin")
          builtin.resume()
        end,
        desc = "Resume the previous telescope picker",
      },
      {
        ";e",
        function()
          local builtin = require("telescope.builtin")
          builtin.diagnostics()
        end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer",
      },
      {
        ";s",
        function()
          local builtin = require("telescope.builtin")
          builtin.treesitter()
        end,
        desc = "Lists Function names, variables, from Treesitter",
      },
      {
        ";m",
        function()
          local builtin = require("telescope.builtin")
          builtin.marks()
        end,
        desc = "List all marks",
      },
      {
        "sF",
        function()
          telescope.extensions.file_browser.file_browser({
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "Open File Browser with the base path",
      },
      {
        "sf",
        function()
          local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
          end
          telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "Open File Browser with the path of the current buffer",
      },
    },
    config = function(_, opts)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local fb_actions = require("telescope").extensions.file_browser.actions
      local lga_actions = require("telescope-live-grep-args.actions")

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        wrap_result = true,
        file_ignore_patterns = {
          ".git/",
          ".cache",
          "%.o",
          "%.a",
          "%.out",
          "%.class",
          "%.pdf",
          "%.mkv",
          "%.mp4",
          "%.zip",
        },
        layout_strategy = "horizontal",
        layout_config = {
          prompt_position = "top",
        },
        path_display = {
          "smart",
        },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          n = {
            ["<C-t>"] = require("trouble.providers.telescope").open_with_trouble,
            ["<C-a>"] = function(bufnr)
              print(bufnr)
              require("trouble.providers.telescope").open_with_trouble(bufnr, "quickfix")
            end,
            ["<C-\\>"] = actions.select_tab,
            ["t"] = actions.select_tab,
            ["vs"] = actions.select_vertical,
            ["ss"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-h>"] = actions.select_horizontal,
          },
          i = {
            ["<C-t>"] = require("trouble.providers.telescope").open_with_trouble,
            ["<C-a>"] = function(bufnr)
              require("trouble.providers.telescope").open_with_trouble(bufnr, "quickfix")
            end,
            ["<C-\\>"] = actions.select_tab,
            ["<C-v>"] = actions.select_vertical,
            ["<C-h>"] = actions.select_horizontal,
          },
        },
      })
      opts.pickers = {
        buffers = {
          sort_lastused = true,
          mappings = {
            n = {
              ["d"] = require("telescope.actions").delete_buffer,
              ["<C-d>"] = require("telescope.actions").delete_buffer,
              ["w"] = function()
                ---@diagnostic disable-next-line: no-unknown
                local selection = action_state.get_selected_entry()
                vim.api.nvim_buf_call(selection.bufnr, function()
                  vim.cmd("w")
                end)
              end,
            },
            i = {
              ["<C-d>"] = require("telescope.actions").delete_buffer,
              ["<C-w>"] = function()
                ---@diagnostic disable-next-line: no-unknown
                local selection = action_state.get_selected_entry()
                vim.api.nvim_buf_call(selection.bufnr, function()
                  vim.cmd("w")
                end)
              end,
            },
          },
        },
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
      }
      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netw and use telescope file browser in its place
          hijack_netrw = true,
          mappings = {
            ["n"] = {
              -- Custom normal mode mappings
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                ---@diagnostic disable-next-line: unused-local
                for i = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                ---@diagnostic disable-next-line: unused-local
                for i = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
              ["<C-\\>"] = actions.select_tab,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            ["i"] = {
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
            },
          },
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("live_grep_args")
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
    end,
  },
}

local themes = {
  popup_list = {
    theme = "popup_list",
    border = true,
    preview = false,
    prompt_title = false,
    results_title = false,
    sorting_strategy = "ascending",
    layout_strategy = "center",
    borderchars = {
      prompt = { "─", "│", "─", "│", "┌", "┐", "┤", "└" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
  },
  popup_extended = {
    theme = "popup_extended",
    prompt_title = false,
    results_title = false,
    layout_strategy = "center",
    layout_config = {
      width = 0.7,
      height = 0.3,
      mirror = true,
      preview_cutoff = 1,
    },
    borderchars = {
      prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
  },
  command_pane = {
    theme = "command_pane",
    preview = false,
    prompt_title = false,
    results_title = false,
    sorting_strategy = "descending",
    layout_strategy = "bottom_pane",
    layout_config = {
      height = 13,
      preview_cutoff = 1,
      prompt_position = "bottom",
    },
  },
  ivy_plus = {
    theme = "ivy_plus",
    preview = false,
    prompt_title = false,
    results_title = false,
    layout_strategy = "bottom_pane",
    layout_config = {
      height = 13,
      preview_cutoff = 120,
      prompt_position = "bottom",
    },
    borderchars = {
      prompt = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      results = { "─", "│", "─", "│", "┌", "┬", "┴", "└" },
      preview = { "─", "│", " ", " ", "─", "┐", "│", " " },
    },
  },
}

local use_layout = function(picker, layout)
  return function()
    picker(themes[layout])
  end
end
local set_keymap = function(lhs, rhs)
  map("n", lhs, rhs, { noremap = true })
end

-- set_keymap("<leader>t", use_layout(telescope_builtin.builtin, "popup_list"))
-- set_keymap("<C-p>", use_layout(telescope_builtin.find_files, "popup_list"))
set_keymap("<C-\\>", use_layout(telescope_builtin.buffers, "popup_list"))
set_keymap("<leader>p", use_layout(telescope_builtin.commands, "command_pane"))
set_keymap(";g", use_layout(telescope_builtin.git_status, "popup_extended"))
set_keymap("<leader>xz", use_layout(telescope_builtin.quickfix, "ivy_plus"))
set_keymap("<leader>sy", use_layout(telescope_builtin.loclist, "ivy_plus"))
set_keymap("<F1>", use_layout(telescope_builtin.help_tags, "popup_extended"))

return M
