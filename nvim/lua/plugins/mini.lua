-- ============================================================================
-- MINI.NVIM PLUGIN CONFIGURATION
--
-- Mini.nvim is a collection of small, independent plugins/modules designed to
-- enhance various aspects of Neovim. This configuration includes features for
-- better text objects, managing surroundings, and a simple statusline.
--
-- For more information, see:
--    https://github.com/echasnovski/mini.nvim
-- ============================================================================

return {
  { -- Mini.nvim plugin suite
    'echasnovski/mini.nvim',

    config = function()
      -- ============================================================================
      -- MINI.AI MODULE
      --
      -- Provides enhanced text objects for selecting or operating on text around
      -- or inside various delimiters. Supports a wide range of customizable
      -- delimiters.
      --
      -- Examples:
      --  - `va)`  : Visually select around parentheses.
      --  - `yinq` : Yank inside the next quotes.
      --  - `ci'`  : Change inside single quotes.
      -- ============================================================================
      require('mini.ai').setup {
        n_lines = 500, -- Search within 500 lines for surrounding delimiters
      }

      -- ============================================================================
      -- MINI.SURROUND MODULE
      --
      -- Provides functionality for adding, deleting, or replacing surroundings like
      -- brackets, quotes, etc.
      --
      -- Examples:
      --  - `saiw)` : Add parentheses around the inner word.
      --  - `sd'`   : Delete single quotes.
      --  - `sr)'`  : Replace parentheses with single quotes.
      -- ============================================================================
      require('mini.surround').setup()

      -- ============================================================================
      -- MINI.STATUSLINE MODULE
      --
      -- A simple and lightweight statusline plugin. It can be easily customized
      -- to display relevant information about the current buffer and cursor.
      -- ============================================================================
      local statusline = require 'mini.statusline'

      -- Configure the statusline
      statusline.setup {
        use_icons = vim.g.have_nerd_font, -- Enable icons if Nerd Fonts are available
      }

      -- Customize the cursor location section to show LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v' -- Format cursor position as "LINE:COLUMN"
      end

      -- ============================================================================
      -- ADDITIONAL INFORMATION
      --
      -- Mini.nvim includes many more modules for features like commenting,
      -- cursor enhancements, and more. Check out the full documentation for
      -- more details: https://github.com/echasnovski/mini.nvim
      -- ============================================================================
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
