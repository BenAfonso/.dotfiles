local M = {
  'milanglacier/yarepl.nvim',
  config = function(_, opts)
    local yarepl = require 'yarepl'

    yarepl.setup {
      -- see `:h buflisted`, whether the REPL buffer should be buflisted.
      buflisted = true,
      -- whether the REPL buffer should be a scratch buffer.
      scratch = true,
      -- the filetype of the REPL buffer created by `yarepl`
      ft = 'REPL',
      -- How yarepl open the REPL window, can be a string or a lua function.
      -- See below example for how to configure this option
      wincmd = 'belowright 15 split',
      -- The available REPL palattes that `yarepl` can create REPL based on.
      -- To disable a built-in meta, set its key to `false`, e.g., `metas = { R = false }`
      metas = {
        aider = require('yarepl.extensions.aider').create_aider_meta(),
        aichat = { cmd = 'aichat', formatter = 'bracketed_pasting', source_func = 'aichat' },
        radian = { cmd = 'radian', formatter = 'bracketed_pasting_no_final_new_line', source_func = 'R' },
        ipython = { cmd = 'ipython', formatter = 'bracketed_pasting', source_func = 'ipython' },
        python = { cmd = 'python', formatter = 'trim_empty_lines', source_func = 'python' },
        R = { cmd = 'R', formatter = 'trim_empty_lines', source_func = 'R' },
        bash = {
          cmd = 'bash',
          formatter = vim.fn.has 'linux' == 1 and 'bracketed_pasting' or 'trim_empty_lines',
          source_func = 'bash',
        },
        zsh = { cmd = 'zsh', formatter = 'bracketed_pasting', source_func = 'bash' },
      },
      -- when a REPL process exits, should the window associated with those REPLs closed?
      close_on_exit = true,
      -- whether automatically scroll to the bottom of the REPL window after sending
      -- text? This feature would be helpful if you want to ensure that your view
      -- stays updated with the latest REPL output.
      scroll_to_bottom_after_sending = true,
      -- Format REPL buffer names as #repl_name#n (e.g., #ipython#1) instead of using terminal defaults
      format_repl_buffers_names = true,
      os = {
        -- Some hacks for Windows. macOS and Linux users can simply ignore
        -- them. The default options are recommended for Windows user.
        windows = {
          -- Send a final `\r` to the REPL with delay,
          send_delayed_cr_after_sending = true,
        },
      },
    }


    -- local keymap = vim.api.nvim_set_keymap
    -- local bufmap = vim.api.nvim_buf_set_keymap
    --
    -- keymap('n', '<Leader>cs', '<Plug>(REPLStart-aichat)', {
    --   desc = 'Start an Aichat REPL',
    -- })
    -- keymap('n', '<Leader>cf', '<Plug>(REPLFocus-aichat)', {
    --   desc = 'Focus on Aichat REPL',
    -- })
    -- keymap('n', '<Leader>ch', '<Plug>(REPLHide-aichat)', {
    --   desc = 'Hide Aichat REPL',
    -- })
    -- keymap('v', '<Leader>cr', '<Plug>(REPLSendVisual-aichat)', {
    --   desc = 'Send visual region to Aichat',
    -- })
    -- keymap('v', '<Leader>cR', '<Plug>(REPLSourceVisual-aichat)', {
    --   desc = 'Source visual region to Aichat',
    -- })
    -- keymap('n', '<Leader>crr', '<Plug>(REPLSendLine-aichat)', {
    --   desc = 'Send lines to Aichat',
    -- })
    -- keymap('n', '<Leader>cr', '<Plug>(REPLSendOperator-aichat)', {
    --   desc = 'Send Operator to Aichat',
    -- })
    -- keymap('n', '<Leader>cr', '<Plug>(REPLSourceOperator-aichat)', {
    --   desc = 'Source Operator to Aichat',
    -- })
    -- keymap('n', '<Leader>ce', '<Plug>(REPLExec-aichat)', {
    --   desc = 'Execute command in aichat',
    -- })
    -- keymap('n', '<Leader>cq', '<Plug>(REPLClose-aichat)', {
    --   desc = 'Quit Aichat',
    -- })


    local ft_to_repl = {
      r = 'radian',
      R = 'radian',
      rmd = 'radian',
      quarto = 'radian',
      markdown = 'radian',
      python = 'ipython',
      sh = 'bash',
    }

    autocmd('FileType', {
      pattern = { 'quarto', 'markdown', 'markdown.pandoc', 'rmd', 'python', 'sh', 'REPL', 'r' },
      group = my_augroup,
      desc = 'set up REPL keymap',
      callback = function()
        local repl = ft_to_repl[vim.bo.filetype]
        repl = repl and ('-' .. repl) or ''

        bufmap(0, 'n', '<LocalLeader>rs', string.format('<Plug>(REPLStart%s)', repl), {
          desc = 'Start an REPL',
        })
        bufmap(0, 'n', '<LocalLeader>rf', '<Plug>(REPLFocus)', {
          desc = 'Focus on REPL',
        })
        bufmap(0, 'n', '<LocalLeader>rv', '<CMD>Telescope REPLShow<CR>', {
          desc = 'View REPLs in telescope',
        })
        bufmap(0, 'n', '<LocalLeader>rh', '<Plug>(REPLHide)', {
          desc = 'Hide REPL',
        })
        bufmap(0, 'v', '<LocalLeader>s', '<Plug>(REPLSendVisual)', {
          desc = 'Send visual region to REPL',
        })
        bufmap(0, 'v', '<LocalLeader>S', '<Plug>(REPLSourceVisual)', {
          desc = 'Source visual region to REPL',
        })
        bufmap(0, 'n', '<LocalLeader>ss', '<Plug>(REPLSendLine)', {
          desc = 'Send line to REPL',
        })
        bufmap(0, 'n', '<LocalLeader>s', '<Plug>(REPLSendOperator)', {
          desc = 'Send operator to REPL',
        })
        bufmap(0, 'n', '<LocalLeader>S', '<Plug>(REPLSourceOperator)', {
          desc = 'Source operator to REPL',
        })
        bufmap(0, 'n', '<LocalLeader>re', '<Plug>(REPLExec)', {
          desc = 'Execute command in REPL',
          expr = true,
        })
        bufmap(0, 'n', '<LocalLeader>rq', '<Plug>(REPLClose)', {
          desc = 'Quit REPL',
        })
        bufmap(0, 'n', '<LocalLeader>rc', '<CMD>REPLCleanup<CR>', {
          desc = 'Clear REPLs.',
        })
        bufmap(0, 'n', '<LocalLeader>rS', '<CMD>REPLSwap<CR>', {
          desc = 'Swap REPLs.',
        })
        bufmap(0, 'n', '<LocalLeader>r?', '<Plug>(REPLStart)', {
          desc = 'Start an REPL from available REPL metas',
        })
        bufmap(0, 'n', '<LocalLeader>ra', '<CMD>REPLAttachBufferToREPL<CR>', {
          desc = 'Attach current buffer to a REPL',
        })
        bufmap(0, 'n', '<LocalLeader>rd', '<CMD>REPLDetachBufferToREPL<CR>', {
          desc = 'Detach current buffer to any REPL',
        })
      end,
    })
  end
}


return M
