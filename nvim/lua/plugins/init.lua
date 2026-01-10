--:w ~/.config/nvim/lua/plugins/init.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
    require("plugins.theme"),
    require("plugins.nvim-tree"),
    require("plugins.treesitter"),
    require("plugins.lsp"),

    -- Statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
            })
        end,
    },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- Git signs
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },

    -- Indent guides
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope = { enabled = true },
            })
        end,
    },

    -- Comment toggling
    {
        "numToStr/Comment.nvim",
        config = true,
    },
    {
        "sphamba/smear-cursor.nvim",
        event = "VeryLazy",
        opts = {
            cursor_color = "#d3cdc3",
            stiffness = 0.8,
            trailing_stiffness = 0.5,
            distance_stop_animating = 0.1,
        },
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" },
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
            { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "Live grep" },
            { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "Find buffers" },
            { "<leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "Help tags" },
        },
        config = true,
    },
}, {
    ui = {
        border = "rounded",
    },
})
