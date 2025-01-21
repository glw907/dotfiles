-- ============================================================================
-- TODO-COMMENTS.NVIM PLUGIN CONFIGURATION
--
-- This plugin highlights TODOs, FIXMEs, NOTES, and other predefined keywords
-- in comments. It provides a quick way to spot important annotations in your
-- codebase and improves workflow efficiency.
--
-- For more information, see:
--    https://github.com/folke/todo-comments.nvim
-- ============================================================================

return {
  {
    'folke/todo-comments.nvim',

    -- Load the plugin when entering Neovim
    event = 'VimEnter',

    -- Required dependency for the plugin
    dependencies = {
      'nvim-lua/plenary.nvim', -- Utility library for Neovim plugins
    },

    -- Plugin options
    opts = {
      signs = false, -- Disable gutter signs for TODOs
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
