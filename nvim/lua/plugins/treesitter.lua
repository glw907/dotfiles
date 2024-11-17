-- ============================================================================
-- NVIM-TREESITTER PLUGIN CONFIGURATION
--
-- Treesitter enhances code highlighting, editing, and navigation in Neovim.
-- It leverages a modern parsing library to provide accurate and efficient
-- syntax highlighting, along with additional features like incremental selection
-- and text objects.
--
-- For more information, see:
--    https://github.com/nvim-treesitter/nvim-treesitter
-- ============================================================================

return {
  {
    'nvim-treesitter/nvim-treesitter',

    -- Automatically update Treesitter parsers after installation
    build = ':TSUpdate',

    -- Specify the main module for Treesitter configurations
    main = 'nvim-treesitter.configs',

    -- Configuration options for Treesitter
    opts = {
      -- Specify the languages to be installed
      ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },

      -- Automatically install missing language parsers
      auto_install = true,

      highlight = {
        enable = true, -- Enable syntax highlighting

        -- Use Vim's regex highlighting for additional languages
        additional_vim_regex_highlighting = { 'ruby' },
      },

      indent = {
        enable = true, -- Enable Treesitter-based indentation
        disable = { 'markdown' }, -- Disable indentation for Markdown
      },

      -- Enable incremental selection for better navigation
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = 'gnn', -- Start incremental selection
          node_incremental = 'grn', -- Expand selection to the next node
          node_decremental = 'grm', -- Shrink selection
        },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
