-- nvim-mail: neovim profile for aerc email composing.
-- Minimal visual style with markdown support and spell check.

-- Leader key
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {
    "shaunsingh/nord.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("nord")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.3",  -- last stable release compatible with nvim 0.9.x
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "markdown", "markdown_inline" },
        highlight = { enable = true },
      })
    end,
  },
}, { ui = { border = "none" } })

-- Editor settings
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.textwidth = 72
vim.opt.formatoptions = "tcrqwn"
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.signcolumn = "no"
vim.opt.showmode = false
vim.opt.laststatus = 0
vim.opt.cursorline = false
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.swapfile = false
vim.opt.termguicolors = true

-- Keybindings
vim.keymap.set("n", "<leader>s", function()
  vim.opt.spell = not vim.opt.spell:get()
end, { desc = "Toggle spell check" })

vim.keymap.set("n", "<leader>q", "<cmd>wq<cr>", { desc = "Save and quit" })

vim.keymap.set("n", "<leader>sig", function()
  local sig = {
    "-- ",
    "Geoffrey L. Wright",
    "h 907-277-9397 | w 907-786-7289",
    "m 907-317-8472 (intermittent)",
  }
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, row, row, false, sig)
end, { desc = "Insert email signature" })
