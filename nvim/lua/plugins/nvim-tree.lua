return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    view = {
      side = "right",
      width = 35,
      relativenumber = true,
      preserve_window_proportions = true,
    },
    renderer = {
      highlight_git = true,
      indent_markers = { enable = true },
      icons = { show = { file = true, folder = true, folder_arrow = true, git = true } },
    },
    filters  = { dotfiles = false, custom = { "^.git$" } },
    git      = { enable = true, ignore = false },
    update_focused_file = { enable = true, update_cwd = true },
    actions = {
       open_file = {
       quit_on_open = false,
       resize_window = false,
       window_picker = { enable = false },
      },
    },
  },
  config = function(_, opts)
    require("nvim-tree").setup(opts)

    -- helper: is the tree window currently focused?
    local function tree_is_focused()
      return vim.bo.filetype == "NvimTree"
    end

    -- toggle focus between tree and last code window
    local function toggle_focus()
      if tree_is_focused() then
        -- jump back to previous window
        vim.cmd.wincmd "p"
      else
        require("nvim-tree.api").tree.focus()
      end
    end

    -- keymaps
    vim.keymap.set("n", "<C-S-e>", toggle_focus, { desc = "Focus/return from tree" })
    vim.keymap.set("n", "<leader>e", toggle_focus, { desc = "Focus/return from tree" })
  end,
}
