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
      -- Plugin-specific configurations
      vim.g.vim_markdown_folding_disabled = 1 -- Disable folding
      vim.g.vim_markdown_new_list_item_indent = 2 -- Two spaces for bullet indentation
      vim.g.vim_markdown_conceal = 1 -- Enable conceal for a cleaner Markdown look
      vim.g.vim_markdown_conceal_code_blocks = 0 -- Do not conceal code blocks
    end,
  },
}

-- vim: ts=2 sts=2 sw=2 et
