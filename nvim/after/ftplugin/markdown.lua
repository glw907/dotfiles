-- ============================================================================
-- MARKDOWN FILETYPE CONFIGURATION
--
-- Configures settings specific to Markdown files in NeoVim, ensuring proper
-- behavior for line wrapping, indentation, and formatting.
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

-- vim: ts=2 sts=2 sw=2 et
