-- ============================================================================
-- VIM-MARKDOWN PLUGIN CONFIGURATION
--
-- Enhances Markdown editing with syntax highlighting, folding, and many other
-- features. This configuration disables folding by default and adjusts bullet
-- indent levels for Markdown lists.
--
-- For more information, see:
--    https://github.com/preservim/vim-markdown
-- ============================================================================

return {
  {
    'preservim/vim-markdown', -- Comprehensive Markdown plugin

    -- Load for Markdown filetypes
    ft = { 'markdown' },

    -- Plugin options and settings
    config = function()
      -- Disable folding by default
      vim.g.vim_markdown_folding_disabled = 1

      -- Use two spaces for bullet indentation in Markdown lists
      vim.g.vim_markdown_new_list_item_indent = 2
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
