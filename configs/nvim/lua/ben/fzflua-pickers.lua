local M = {}

M.files = function(opts)
  opts = opts or {}

  local fzflua = require("fzf-lua")

  local safe_cwd = function(t)
    return vim.t.Cwd
  end

  if not opts.cwd then
    opts.cwd = safe_cwd(vim.t.Cwd)
  end
  local cmd = nil
  if vim.fn.executable("fd") == 1 then
    local fzfutils = require("fzf-lua.utils")
    -- fzf-lua.defaults#defaults.files.fd_opts
    cmd = string.format(
      [[fd --color=never --type f --hidden --follow --exclude .git -x printf "{}: {/} %s\n"]],
      fzfutils.ansi_codes.grey("{//}")
    )
    opts.fzf_opts = {
      -- process ansi colors
      ["--ansi"] = "",
      ["--with-nth"] = "2..",
      ["--delimiter"] = "\\s",
      ["--tiebreak"] = "begin,index",
    }
    -- opts._fmt = opts._fmt or {}
    -- opts._fmt.from = function(entry, _opts)
    --   local s = fzfutils.strsplit(entry, ' ')
    --   return s[3]
    -- end
  end
  opts.cmd = cmd

  opts.winopts = {
    fullscreen = false,
    height = 0.90,
    width = 1,
  }
  opts.ignore_current_file = true

  return fzflua.files(opts)
end

return M
