function P(table)
  print(vim.inspect(table))
end

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.o.expandtab = true
vim.bo.softtabstop = 0

vim.opt.scrolloff = 10

vim.opt.sidescrolloff = 30

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true
vim.opt_local.showbreak = "⋮ "

vim.o.exrc = true
vim.o.colorcolumn = "80"
