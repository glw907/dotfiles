-- ============================================================================
-- GITSIGNS.NVIM PLUGIN CONFIGURATION
--
-- Gitsigns.nvim adds Git-related signs to the gutter and provides utilities
-- for managing changes directly from Neovim. It includes features like hunk
-- navigation, staging, resetting, and interactive diff views, enhancing the
-- Git workflow within the editor.
--
-- For more information, see:
--    https://github.com/lewis6991/gitsigns.nvim
-- ============================================================================

return {
  { -- Git integration for Neovim
    'lewis6991/gitsigns.nvim',

    -- Configuration options for gitsigns.nvim
    opts = {
      signs = {
        -- Define symbols for Git-related changes
        add = { text = '+' }, -- Added lines
        change = { text = '~' }, -- Modified lines
        delete = { text = '_' }, -- Deleted lines
        topdelete = { text = '‾' }, -- Top of deleted lines
        changedelete = { text = '~' }, -- Modified and deleted lines
      },

      -- Function to set up key mappings when the plugin attaches to a buffer
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        -- Helper function for creating key mappings
        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr -- Restrict keymaps to the current buffer
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        -- Navigation mappings for Git hunks
        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next' -- Jump to the next hunk
          end
        end, { desc = 'Jump to next Git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev' -- Jump to the previous hunk
          end
        end, { desc = 'Jump to previous Git [c]hange' })

        -- Actions for staging and resetting hunks
        -- Visual mode mappings
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Stage selected Git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'Reset selected Git hunk' })

        -- Normal mode mappings
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Git [s]tage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Git [r]eset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Git [S]tage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'Git [u]ndo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Git [R]eset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Git [p]review hunk' })
        map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Git [b]lame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Git [d]iff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '@'
        end, { desc = 'Git [D]iff against last commit' })

        -- Toggle mappings
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = '[T]oggle Git show [b]lame line' })
        map('n', '<leader>tD', gitsigns.toggle_deleted, { desc = '[T]oggle Git show [D]eleted lines' })
      end,
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
