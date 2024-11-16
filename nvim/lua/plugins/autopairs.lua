-- ============================================================================
-- NVIM AUTOPAIRS PLUGIN CONFIGURATION
--
-- This plugin automatically closes and pairs brackets, quotes, and other
-- delimiters in insert mode to improve coding efficiency and reduce errors.
-- Additionally, it integrates with nvim-cmp to provide intelligent pairing
-- for function and method completions.
--
-- For more information, see:
--    https://github.com/windwp/nvim-autopairs
-- ============================================================================

return {
  'windwp/nvim-autopairs',

  -- Load the plugin when entering Insert mode
  event = 'InsertEnter',

  -- Optional dependency: hrsh7th/nvim-cmp
  -- Provides completion integration for better pairing behavior
  dependencies = { 'hrsh7th/nvim-cmp' },

  config = function()
    -- Basic setup for autopairs
    require('nvim-autopairs').setup {}

    -- Integrate autopairs with nvim-cmp for intelligent pairing
    -- Automatically adds opening delimiters like `(` when confirming a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'

    -- Attach `on_confirm_done` event to nvim-cmp for autopairs functionality
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
-- vim: ts=2 sts=2 sw=2 et
