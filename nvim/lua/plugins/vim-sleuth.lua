-- ============================================================================
-- VIM-SLEUTH PLUGIN CONFIGURATION
--
-- Vim-sleuth automatically detects `tabstop`, `shiftwidth`, and `expandtab`
-- settings based on the indentation style of the current file. This ensures
-- consistent formatting and simplifies working with files that have varying
-- indentation styles.
--
-- For more information, see:
--    https://github.com/tpope/vim-sleuth
-- ============================================================================

return {
  'tpope/vim-sleuth', -- Automatically detect tab and indent settings

  -- Load the plugin immediately without requiring specific events or commands
  lazy = false,
}
-- vim: ts=2 sts=2 sw=2 et
