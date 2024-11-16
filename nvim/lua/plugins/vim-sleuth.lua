-- ============================================================================
-- PLUGIN: VIM-SLEUTH
--
-- Automatically detects `tabstop`, `shiftwidth`, and `expandtab` settings based
-- on the indentation style of the current file.
--
-- For more information, see:
--    https://github.com/tpope/vim-sleuth
-- ============================================================================
return {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  lazy = false, -- Load immediately; no specific event or command needed
}
