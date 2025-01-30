-- ============================================================================
-- HTML FILETYPE CONFIGURATION
--
-- Configures settings specific to HTML files in NeoVim, ensuring proper
-- indentation, formatting, and visual behavior tailored to HTML development.
-- Includes soft wrapping that aligns with the start of the HTML element.
--
-- This file is loaded automatically for HTML filetypes via the `after`
-- directory structure.
-- ============================================================================

-- Enable soft wrapping for long lines
vim.opt_local.wrap = true

-- Break lines at word boundaries
vim.opt_local.linebreak = true

-- Indent wrapped lines visually to align with the parent element
vim.opt_local.breakindent = true

-- Set the amount of visual indentation for wrapped lines
vim.opt_local.breakindentopt = 'shift:2' -- Indent by two spaces

-- Use spaces instead of tabs for indentation
vim.opt_local.expandtab = true

-- Set indentation to two spaces
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2

-- Enable auto-indentation for HTML
vim.opt_local.smartindent = true

-- Enable line numbering for better navigation
vim.opt_local.number = true
vim.opt_local.relativenumber = true

-- Define custom key mappings for soft-wrapped line navigation
vim.keymap.set('n', 'j', 'gj', { buffer = true, silent = true }) -- Move down by screen line
vim.keymap.set('n', 'k', 'gk', { buffer = true, silent = true }) -- Move up by screen line
vim.keymap.set('n', '0', 'g0', { buffer = true, silent = true }) -- Start of screen line
vim.keymap.set('n', '$', 'g$', { buffer = true, silent = true }) -- End of screen line

-- vim: ts=2 sts=2 sw=2 et
