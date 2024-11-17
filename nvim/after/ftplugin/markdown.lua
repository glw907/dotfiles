-- ============================================================================
-- MARKDOWN FILETYPE CONFIGURATION
--
-- This configuration applies specific settings for Markdown files to enhance
-- readability and editing experience. It enables soft wrapping, limits the line
-- width to 80 characters, and improves readability with word-based line breaks
-- and indentation for wrapped lines. Existing lines are reformatted to adhere
-- to the text width automatically when the file is opened.
-- ============================================================================

-- Enable soft line wrapping for better readability
vim.opt_local.wrap = true

-- Limit line width to 80 characters for consistent formatting
vim.opt_local.textwidth = 80

-- Break lines at word boundaries to avoid cutting words
vim.opt_local.linebreak = true

-- Indent wrapped lines to align with the parent line
vim.opt_local.breakindent = true

-- Reformat existing lines to 80 characters when the file is opened
-- This applies to the entire buffer for consistent soft wrapping
vim.cmd [[silent! normal ggVGgq]]
