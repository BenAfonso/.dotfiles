return {
  "akinsho/toggleterm.nvim",
  config = function()
    require("toggleterm").setup({
      shade_terminals = false,
      shell = "zsh",
      highlights = {
        StatusLine = { guifg = "#ffffff", guibg = "#0E1018" },
        StatusLineNC = { guifg = "#ffffff", guibg = "#0E1018" },
      },
    })

    local Terminal = require("toggleterm.terminal").Terminal

    local lg_cmd = "lazygit -w $PWD"
    if vim.v.servername ~= nil then
      lg_cmd = string.format("NVIM_SERVER=%s lazygit -ucf ~/.config/nvim/lazygit.yml -w $PWD", vim.v.servername)
    end

    vim.env.GIT_EDITOR = "nvr -cc split --remote-wait +'set bufhidden=wipe'"

    local lazygit = Terminal:new({
      cmd = lg_cmd,
      count = 5,
      direction = "float",
      float_opts = {
        border = "double",
        width = function()
          return vim.o.columns
        end,
        height = function()
          return vim.o.lines
        end,
      },
      -- function to run on opening the terminal
      on_open = function(term)
        vim.cmd("startinsert!")
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
    })

    function Edit(fn, line_number)
      local edit_cmd = string.format(":e %s", fn)
      if line_number ~= nil then
        edit_cmd = string.format(":e +%d %s", line_number, fn)
      end
      vim.cmd(edit_cmd)
    end

    function Lazygit_toggle()
      lazygit:toggle()
    end

    vim.keymap.set(
      "n",
      "<space>tv",
      ":ToggleTerm size=15 direction=horizontal<cr>",
      { silent = true, desc = "[T]erminal [V]ertical" }
    )
    vim.keymap.set(
      "n",
      "<space>th",
      ":ToggleTerm size=60 direction=vertical<cr>",
      { silent = true, desc = "[T]erminal [H]orizontal" }
    )
    vim.keymap.set("n", "<leader>go", "<cmd>lua Lazygit_toggle()<CR>", { silent = true, desc = "[O]pen Lazygit" })

    -- local Util = require("lazyvim.util")
    --
    -- -- Function to check clipboard with retries
    -- local function getRelativeFilepath(retries, delay)
    --   local relative_filepath
    --   for i = 1, retries do
    --     relative_filepath = vim.fn.getreg("+")
    --     if relative_filepath ~= "" then
    --       return relative_filepath -- Return filepath if clipboard is not empty
    --     end
    --     vim.loop.sleep(delay) -- Wait before retrying
    --   end
    --   return nil -- Return nil if clipboard is still empty after retries
    -- end
    --
    -- -- Function to handle editing from Lazygit
    -- function LazygitEdit(original_buffer)
    --   local current_bufnr = vim.fn.bufnr("%")
    --   local channel_id = vim.fn.getbufvar(current_bufnr, "terminal_job_id")
    --
    --   if not channel_id then
    --     vim.notify("No terminal job ID found.", vim.log.levels.ERROR)
    --     return
    --   end
    --
    --   vim.fn.chansend(channel_id, "\15") -- \15 is <c-o>
    --   vim.cmd("close") -- Close Lazygit
    --
    --   local relative_filepath = getRelativeFilepath(5, 50)
    --   if not relative_filepath then
    --     vim.notify("Clipboard is empty or invalid.", vim.log.levels.ERROR)
    --     return
    --   end
    --
    --   local winid = vim.fn.bufwinid(original_buffer)
    --
    --   if winid == -1 then
    --     vim.notify("Could not find the original window.", vim.log.levels.ERROR)
    --     return
    --   end
    --
    --   vim.fn.win_gotoid(winid)
    --   vim.cmd("e " .. relative_filepath)
    -- end
    --
    -- -- Function to start Lazygit in a floating terminal
    -- function StartLazygit()
    --   local current_buffer = vim.api.nvim_get_current_buf()
    --   local float_term = Util.terminal.open({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false })
    --
    --   vim.api.nvim_buf_set_keymap(
    --     float_term.buf,
    --     "t",
    --     "<c-b>",
    --     string.format([[<Cmd>lua LazygitEdit(%d)<CR>]], current_buffer),
    --     { noremap = true, silent = true }
    --   )
    -- end
    --
    -- vim.api.nvim_set_keymap("n", "<leader>gg", [[<Cmd>lua StartLazygit()<CR>]], { noremap = true, silent = true })
    --
  end,
}
