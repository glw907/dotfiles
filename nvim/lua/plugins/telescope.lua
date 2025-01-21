-- ============================================================================
-- TELESCOPE.NVIM PLUGIN CONFIGURATION
--
-- Telescope is a highly extensible fuzzy finder for Neovim. It allows you to
-- search files, keymaps, diagnostics, and much more across your workspace.
-- This configuration includes additional extensions like `fzf` and `ui-select`
-- for improved functionality and user experience.
--
-- For more information, see:
--    https://github.com/nvim-telescope/telescope.nvim
-- ============================================================================

return {
  { -- Main Telescope plugin
    'nvim-telescope/telescope.nvim',

    -- Load on VimEnter for availability after starting Neovim
    event = 'VimEnter',
    branch = '0.1.x', -- Use the specified stable branch

    dependencies = {
      'nvim-lua/plenary.nvim', -- Required utility functions for Telescope
      {
        'nvim-telescope/telescope-fzf-native.nvim', -- FZF extension for faster searching
        build = 'make', -- Build FZF when the plugin is installed or updated
        cond = function()
          return vim.fn.executable 'make' == 1 -- Only load if `make` is available
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' }, -- UI selection menu
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font }, -- Optional icons support
    },

    config = function()
      -- ============================================================================
      -- TELESCOPE SETUP
      --
      -- Telescope offers a rich set of features for fuzzy searching. This section
      -- configures the plugin and its extensions to provide default mappings,
      -- behaviors, and themes.
      -- ============================================================================

      require('telescope').setup {
        -- Configure extensions and themes
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(), -- Use dropdown theme for UI select
          },
        },
      }

      -- Load Telescope extensions
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- ============================================================================
      -- KEY MAPPINGS
      --
      -- Define key mappings to access Telescope's various features easily.
      -- These include searching files, keymaps, diagnostics, and more.
      -- ============================================================================

      local builtin = require 'telescope.builtin'

      -- Basic search functionalities
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      -- Advanced searches
      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' } -- Search Neovim configuration files
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
