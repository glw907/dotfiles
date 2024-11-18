-- ============================================================================
-- MARKDOWN FILETYPE CONFIGURATION
--
-- Configures settings specific to Markdown files in NeoVim, ensuring proper
-- behavior for line wrapping, indentation, formatting, and navigation of
-- soft-wrapped lines.
--
-- This file is loaded automatically for Markdown filetypes via the `after`
-- directory structure.
-- ============================================================================

-- Wrap lines that exceed the window width
vim.opt_local.wrap = true

-- Avoid breaking in the middle of words
vim.opt_local.linebreak = true

-- Indent wrapped lines visually to match the parent
vim.opt_local.breakindent = true

-- Disable line numbering
vim.opt_local.number = false
vim.opt_local.relativenumber = false

-- Set tab width to two space
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2

-- Navigation for soft-wrapped lines
vim.keymap.set('n', 'j', 'gj', { buffer = true, silent = true }) -- Move down by screen line
vim.keymap.set('n', 'k', 'gk', { buffer = true, silent = true }) -- Move up by screen line
vim.keymap.set('n', '0', 'g0', { buffer = true, silent = true }) -- Start of screen line
vim.keymap.set('n', '$', 'g$', { buffer = true, silent = true }) -- End of screen line

-- vim: ts=2 sts=2 sw=2 et
