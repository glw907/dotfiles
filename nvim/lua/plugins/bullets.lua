-- ============================================================================
-- BULLETS.VIM PLUGIN CONFIGURATION
--
-- Provides intelligent auto-indentation, list formatting, and wrapping for
-- ordered and unordered lists in Markdown and other filetypes.
--
-- For more information, see:
--    https://github.com/dkarter/bullets.vim
-- ============================================================================

return {
  {
    'dkarter/bullets.vim', -- Plugin for better list management in text files

    -- Load for specific filetypes
    ft = { 'markdown', 'text' },

    -- Plugin options and settings
    config = function()
      -- Enable auto-indentation for lists
      vim.g.bullets_enable_auto_indent = 1

      -- Use two spaces for list item indentation
      vim.g.bullets_set_mappings = 1
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
