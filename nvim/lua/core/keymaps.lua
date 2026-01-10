local keymap = vim.keymap.set

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Toggle file tree with Ctrl+Shift+E
keymap("n", "<C-S-e>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
keymap("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
keymap("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase window width" })

-- Buffer navigation
keymap("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
keymap("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
keymap("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close buffer" })

-- Better indenting
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- Move lines up/down
keymap("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
keymap("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Save file
keymap("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file" })

-- Clear search highlight
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Shift-L
vim.keymap.set("n", "<S-l>", "L", { desc = "Go to bottom visible line" })
-- Shift-H
vim.keymap.set("n", "<S-h>", "G", { desc = "Go to top visible line" })

-- Write to all files
vim.keymap.set("n", "<C-s>", "<Cmd>wa<CR>", { desc = "Save all buffers" })
vim.keymap.set("i", "<C-s>", "<Esc><Cmd>wa<CR>", { desc = "Save all buffers" })

-- Multi cursors
vim.g.VM_maps = {
    ['Find Under'] = '<C-n>',
    ['Visual cursors'] = 'I',
}

vim.g.VM_maps['Visual Add'] = 'A'
