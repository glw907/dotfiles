-- ============================================================================
-- TOKYONIGHT.NVIM PLUGIN CONFIGURATION
--
-- This plugin provides the "tokyonight" colorscheme for Neovim. It includes
-- several styles (e.g., `storm`, `moon`, `day`, and `night`) and supports
-- customization of highlights.
--
-- For more information, see:
--    https://github.com/folke/tokyonight.nvim
-- ============================================================================

return {
  {
    'folke/tokyonight.nvim',

    -- Ensure the colorscheme is loaded before other plugins
    priority = 1000,

    init = function()
      -- Load the colorscheme
      -- Available styles include 'tokyonight-night', 'tokyonight-storm',
      -- 'tokyonight-moon', and 'tokyonight-day'.
      vim.cmd.colorscheme 'tokyonight-night'

      -- Example: Customize highlights
      vim.cmd.hi 'Comment gui=none' -- Disable special formatting for comments
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
