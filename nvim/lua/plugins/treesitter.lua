return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },   -- load after files are open
  config = function()
    -- safety check: make sure the plugin is really there
    local ok, ts = pcall(require, "nvim-treesitter.configs")
    if not ok then
      vim.notify("treesitter not ready yet, skipping config", vim.log.levels.WARN)
      return
    end

    ts.setup({
      ensure_installed = {
        "lua", "rust", "toml", "json", "yaml",
        "markdown", "markdown_inline", "vim", "vimdoc", "bash",
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
    })
  end,
}
