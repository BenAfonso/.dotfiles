local function filenameFirst(_, path)
  local parent = vim.fs.dirname(path)
  local tail = vim.fs.basename(path)
  if parent == "." then
    return tail
  else
    -- Truncate end of path to something like '.../modules/path/extra/file.ts'
    local length = #parent
    if length >= 25 then
      local splits = {}
      for split in string.gmatch(parent, "[^/]+") do
        table.insert(splits, split)
      end
      local len = 0
      local path = ""
      for i = #splits, 1, -1 do
        if len + #splits[i] > 25 then
          break
        else
          len = len + #splits[i]
          path = splits[i] .. "/" .. path
        end
      end
      parent = "..." .. path
    end
    return string.format("%s\t\t%s", tail, parent)
  end
end

local actions = require("telescope.actions")
local previewers = require("telescope.previewers")

local Job = require("plenary.job")
local _bad = { ".*%.csv", ".*%.min.js" } -- Put all filetypes that slow you down in this array
local bad_files = function(filepath)
  for _, v in ipairs(_bad) do
    if filepath:match(v) then
      return false
    end
  end
  return true
end

-- Prevent showing large files in telescope
---@diagnostic disable-next-line: redefined-local
local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}
  if opts.use_ft_detect == nil then
    opts.use_ft_detect = true
  end
  opts.use_ft_detect = opts.use_ft_detect == false and false or bad_files(filepath)
  filepath = vim.fn.expand(filepath)

  Job:new({
    command = "file",
    args = { "--mime-type", "-b", filepath },
    on_exit = function(j)
      local mime_type = vim.split(j:result()[1], "/")[1]
      if mime_type == "text" then
        vim.loop.fs_stat(filepath, function(_, stat)
          if not stat then
            return
          end
          if stat.size > 100000 then
            vim.schedule(function()
              vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "FILE TOO LARGE" })
            end)
          else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
          end
        end)
      else
        -- maybe we want to write something to the buffer here
        vim.schedule(function()
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "BINARY" })
        end)
      end
    end,
  }):sync()
end

local M = { -- Fuzzy Finder (files, lsp, etc)
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { -- If encountering errors, see telescope-fzf-native README for install instructions
      "nvim-telescope/telescope-fzf-native.nvim",

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = "make",

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    {
      "nvim-telescope/telescope-file-browser.nvim",
      enabled = false,
    },
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      version = "^1.0.0",
    },

    -- Useful for getting pretty icons, but requires special font.
    --  If you already have a Nerd Font, or terminal set up with fallback fonts
    --  you can enable this
    -- { 'nvim-tree/nvim-web-devicons' }
  },
  config = function()
    local action_state = require("telescope.actions.state")
    -- local fb_actions = require("telescope").extensions.file_browser.actions
    local lga_actions = require("telescope-live-grep-args.actions")

    require("telescope").setup({
      defaults = {
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },

        -- Icons
        prompt_prefix = "  ",
        selection_caret = "  ",
        entry_prefix = " ",
        multi_icon = "  ",

        file_sorter = require("telescope.sorters").get_fzy_sorter,
        -- buffer_previewer_maker = new_maker,
        wrap_result = true,
        file_ignore_patterns = {
          ".git/",
          ".cache",
          "%.min.js$",
          "%.o$",
          "%.a$",
          "%.out",
          "%.class",
          "%.pdf",
          "%.mkv",
          "%.mp4",
          "%.zip",
        },
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "bottom",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        path_display = { "shorten" },
        sorting_strategy = "descending",
        winblend = 0,
        mappings = {
          n = {
            ["q"] = function(bufnr)
              actions.close(bufnr)
            end,
            ["<C-t>"] = require("trouble.sources.telescope").open,
            ["<C-q>"] = function(bufnr)
              actions.send_to_qflist(bufnr)
              require("trouble").open("quickfix")
            end,
            ["<C-a>"] = function(bufnr)
              require("trouble.sources.telescope").open(bufnr)
            end,
            ["<C-\\>"] = actions.select_tab,
            ["te"] = actions.select_tab,
            ["sv"] = actions.select_vertical,
            ["sh"] = actions.select_horizontal,
            ["<C-v>"] = actions.select_vertical,
            ["<C-h>"] = actions.select_horizontal,
            ["/"] = function()
              vim.cmd("startinsert")
            end,
          },
          i = {
            ["<C-q>"] = function(bufnr)
              actions.send_to_qflist(bufnr)
              require("trouble").open("quickfix")
            end,
            ["<C-t>"] = require("trouble.sources.telescope").open,
            ["<C-a>"] = function(bufnr)
              require("trouble.sources.telescope").open(bufnr, "quickfix")
            end,
            ["<C-\\>"] = actions.select_tab,
            ["<C-v>"] = actions.select_vertical,
            ["<C-h>"] = actions.select_horizontal,
          },
        },
      },
      pickers = {
        help_tags = {
          mappings = {
            i = {
              ["<CR>"] = actions.select_vertical,
            },
            n = {
              ["<CR>"] = actions.select_vertical,
              ["ff"] = actions.select_default,
            },
          },
        },
        buffers = {
          path_display = filenameFirst,
          sort_lastused = true,
          theme = "ivy",
          layout_config = {
            horizontal = {
              prompt_position = "bottom",
              preview_width = 0.55,
              results_width = 0.8,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },
          mappings = {
            n = {
              ["dd"] = require("telescope.actions").delete_buffer,
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
        git_status = {
          path_display = filenameFirst,
        },
        find_files = {
          path_display = filenameFirst,
          -- path_display = {
          --   truncate = 3,
          -- },
        },
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
        colorscheme = {
          enable_preview = true,
        },
      },
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
        -- file_browser = {
        --   theme = "dropdown",
        --   -- disables netw and use telescope file browser in its place
        --   hijack_netrw = true,
        --   mappings = {
        --     ["n"] = {
        --       -- Custom normal mode mappings
        --       ["N"] = fb_actions.create,
        --       ["h"] = fb_actions.goto_parent_dir,
        --       ["<C-u>"] = function(prompt_bufnr)
        --         ---@diagnostic disable-next-line: unused-local
        --         for i = 1, 10 do
        --           actions.move_selection_previous(prompt_bufnr)
        --         end
        --       end,
        --       ["<C-d>"] = function(prompt_bufnr)
        --         ---@diagnostic disable-next-line: unused-local
        --         for i = 1, 10 do
        --           actions.move_selection_next(prompt_bufnr)
        --         end
        --       end,
        --       ["<C-\\>"] = actions.select_tab,
        --       ["<PageUp>"] = actions.preview_scrolling_up,
        --       ["<PageDown>"] = actions.preview_scrolling_down,
        --     },
        --   },
        -- },
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            ["i"] = {
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
            },
          },
        },
      },
    })

    -- Enable telescope extensions, if they are installed
    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "ui-select")

    pcall(require("telescope").load_extension("live_grep_args"))

    -- pcall(require("telescope").load_extension("file_browser"))

    -- See `:help telescope.builtin`
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>sP", function()
      builtin.find_files({
        cwd = require("lazy.core.config").options.root,
      })
    end, { desc = "[F] [P]lugin File" })

    -- vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    -- vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    -- -- vim.keymap.set("n", "<C-p>", builtin.find_files, { desc = "[S]earch [F]iles" })
    -- vim.keymap.set("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
    -- vim.keymap.set("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    -- vim.keymap.set("n", "<leader>sb", builtin.current_buffer_fuzzy_find, { desc = "[S]earch current [B]uffer" })
    -- vim.keymap.set("n", "<leader>st", builtin.colorscheme, { desc = "[S]earch [T]heme" })
    --
    -- vim.keymap.set("n", ";r", telescope.extensions.live_grep_args.live_grep_args, { desc = "[S]earch by [G]rep" })
    -- vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    -- vim.keymap.set("n", ";;", builtin.resume, { desc = "[S]earch [R]esume" })
    -- vim.keymap.set("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    -- vim.keymap.set("n", "\\\\", builtin.buffers, { desc = "Find existing buffers" })


    vim.keymap.set("n", "<leader>sg", function()
      require("fzf-lua").grep({
        raw_cmd =
        [[git status -su | rg "^\s*M" | cut -d ' ' -f3 | xargs rg --hidden --column --line-number --no-heading --color=always --with-filename -e '']],
      })
    end, { desc = "[S]earch in [G]it diff" })
    -- vim.keymap.set(
    --   "n",
    --   "<leader>sg",
    --   telescope.extensions.live_grep_args.live_grep_args,
    --   { desc = "[S]earch by [G]rep" }
    -- )
    -- vim.keymap.set("n", ";r", builtin.live_grep, { desc = "[S]earch by [G]rep" })

    -- NOTE: File Browser
    -- local open_file_browser = function()
    --   local function telescope_buffer_dir()
    --     return vim.fn.expand("%:p:h")
    --   end
    --   telescope.extensions.file_browser.file_browser({
    --     path = "%:p:h",
    --     cwd = telescope_buffer_dir(),
    --     respect_gitignore = false,
    --     hidden = true,
    --     grouped = true,
    --     previewer = false,
    --     initial_mode = "normal",
    --     layout_config = { height = 40 },
    --   })
    -- end
    -- vim.keymap.set("n", "<leader>sf", open_file_browser, { desc = "Open file browser" })

    -- vim.keymap.set("n", "<leader>sf", function()
    --   require("ben.fzflua-pickers").files({})
    -- end, { desc = "Open file browser" })

    -- vim.keymap.set("n", "sf", open_file_browser, { desc = "Open file browser" })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set("n", "<leader>/", function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    -- Also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, { desc = "[S]earch [/] in Open Files" })

    -- Shortcut for searching your neovim configuration files
    vim.keymap.set("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[S]earch [N]eovim files" })

    vim.keymap.set({ "n" }, "<leader>eb", function()
      require("ben.telescope.find_files").find_files({
        prompt_title = "Scripts",
        cwd = vim.fn.getenv("DOTFILES") .. "/bin",
      })
    end, { noremap = true, desc = "Search custom [B]inaries" })

    vim.keymap.set(
      { "n" },
      "<leader>sc",
      require("ben.telescope.config_picker"),
      { noremap = true, desc = "[S]earch [C]onfig" }
    )

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "TelescopeResults",
      callback = function(ctx)
        vim.api.nvim_buf_call(ctx.buf, function()
          vim.fn.matchadd("TelescopeParent", "\t\t.*$")
          vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
        end)
      end,
    })
  end,
}

return M
