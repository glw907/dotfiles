-- ============================================================================
-- NEO-TREE.NVIM PLUGIN CONFIGURATION
--
-- Neo-tree is a powerful file explorer for Neovim that provides an intuitive
-- interface for browsing the file system. It supports features like integration
-- with devicons and advanced window mappings for improved navigation.
--
-- For more information, see:
--    https://github.com/nvim-neo-tree/neo-tree.nvim
-- ============================================================================

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*', -- Automatically fetch the latest stable version

  -- Dependencies required for Neo-tree
  dependencies = {
    'nvim-lua/plenary.nvim', -- Utility functions for Neovim plugins
    'nvim-tree/nvim-web-devicons', -- File type icons (optional but recommended)
    'MunifTanjim/nui.nvim', -- UI components for enhanced user experience
  },

  -- Command to launch Neo-tree
  cmd = 'Neotree',

  -- Key mappings for Neo-tree
  keys = {
    {
      '\\', -- Key to reveal the current file in Neo-tree
      ':Neotree reveal<CR>',
      desc = 'NeoTree reveal',
      silent = true, -- Suppress command output
    },
  },

  -- Plugin options and configurations
  opts = {
    filesystem = {
      window = {
        mappings = {
          -- Map `\` to close the Neo-tree window
          ['\\'] = 'close_window',
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
