function P(table)
  print(vim.inspect(table))
end

vim.opt.scrolloff = 10

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.showbreak = "⋮ "

vim.o.exrc = true
