-- ============================================================================
-- BASIC OPTIONS
--
-- This file defines basic Neovim options to customize its behavior. Adjust
-- these settings as needed to suit your preferences.
--
-- For more information, see:
--    :help vim.opt
--    :help option-list
-- ============================================================================

-- Line numbers and display
vim.opt.number = true -- Show line numbers by default
-- vim.opt.relativenumber = true -- Enable relative line numbers (optional)

-- Mouse and mode display
vim.opt.mouse = 'a' -- Enable mouse mode for resizing splits
vim.opt.showmode = false -- Hide mode display (e.g., "-- INSERT --")

-- Clipboard integration
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim
end)

-- Indentation and undo
vim.opt.breakindent = true -- Enable break indent
vim.opt.undofile = true -- Save undo history to a file

-- Search behavior
vim.opt.ignorecase = true -- Case-insensitive searching by default
vim.opt.smartcase = true -- Case-sensitive if uppercase or \C used

-- UI elements
vim.opt.signcolumn = 'yes' -- Always show the sign column
vim.opt.updatetime = 250 -- Decrease update time for faster response
vim.opt.timeoutlen = 300 -- Decrease wait time for mapped sequences

-- Split window behavior
vim.opt.splitright = true -- Open vertical splits to the right
vim.opt.splitbelow = true -- Open horizontal splits below

-- Whitespace display
vim.opt.list = true -- Display whitespace characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Define how whitespace is displayed

-- Command preview
vim.opt.inccommand = 'split' -- Preview substitutions live as you type

-- Cursor and scrolling
vim.opt.cursorline = true -- Highlight the current line
vim.opt.scrolloff = 10 -- Keep a minimum number of lines around the cursor

-- vim: ts=2 sts=2 sw=2 et
