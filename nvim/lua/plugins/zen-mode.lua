-- ============================================================================
-- ZEN MODE PLUGIN CONFIGURATION
--
-- Provides a distraction-free writing environment by centering text
-- and hiding extraneous UI elements. This configuration ensures the
-- plugin is active only for Markdown files.
--
-- For more information, see:
--    https://github.com/folke/zen-mode.nvim
-- ============================================================================

return {
  {
    'folke/zen-mode.nvim', -- Plugin for distraction-free writing

    -- Load for Markdown filetypes only
    ft = { 'markdown' },

    -- Plugin options and settings
    config = function()
      require('zen-mode').setup {
        window = {
          -- Set the width of the Zen window
          width = 80,
          -- Keep the Zen window at the center
          options = {
            number = false, -- Disable line numbers
            relativenumber = false, -- Disable relative line numbers
            cursorline = false, -- Disable cursor line highlighting
          },
        },
        plugins = {
          options = {
            enabled = true,
            showcmd = false, -- Disable command feedback
            ruler = false, -- Disable the ruler
          },
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
