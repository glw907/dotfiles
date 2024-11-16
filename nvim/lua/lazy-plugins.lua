-- ============================================================================
-- PLUGIN CONFIGURATION AND INSTALLATION
--
-- This file manages plugins using the `lazy.nvim` plugin manager. Plugins
-- can be added, configured, and updated here.
--
-- To check the current status of your plugins:
--    :Lazy
--
-- To update plugins:
--    :Lazy update
--
-- For help in the Lazy menu, press `?`. Use `:q` to close the menu.
-- ============================================================================

require('lazy').setup({
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Modular approach: Plugin configurations are included via require statements
  require 'plugins/gitsigns',
  require 'plugins/which-key',
  require 'plugins/telescope',
  require 'plugins/lspconfig',
  require 'plugins/conform',
  require 'plugins/cmp',
  require 'plugins/tokyonight',
  require 'plugins/todo-comments',
  require 'plugins/mini',
  require 'plugins/treesitter',
  require 'plugins/vim-sleuth',
  require 'plugins/comment',
  require 'plugins/vim-markdown',
}, {
  ui = {
    -- Use Nerd Font icons if available, otherwise define Unicode icons
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
