local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true

opt.fillchars = { eob = " " }
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = false
opt.incsearch = true

opt.termguicolors = true
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.clipboard = "unnamedplus"
opt.undofile = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.swapfile = false

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
