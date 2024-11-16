-- ============================================================================
-- NVIM-LINT PLUGIN CONFIGURATION
--
-- This plugin provides asynchronous linting for various file types in Neovim.
-- It is lightweight, highly configurable, and integrates well with other
-- Neovim tools. This configuration includes specific linters and an autocommand
-- for triggering linting on certain events.
--
-- For more information, see:
--    https://github.com/mfussenegger/nvim-lint
-- ============================================================================

return {
  { -- Asynchronous linting for Neovim
    'mfussenegger/nvim-lint',

    -- Trigger linting setup on file read or new file creation
    event = { 'BufReadPre', 'BufNewFile' },

    config = function()
      local lint = require 'lint'

      -- Configure linters by filetype
      lint.linters_by_ft = {
        markdown = { 'markdownlint' }, -- Use `markdownlint` for Markdown files
      }

      -- Example: Allow plugins to extend `linters_by_ft`
      -- Uncomment the following code to add linters dynamically:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }

      -- Example: Disabling default linters
      -- Uncomment the following lines to prevent default linters from causing errors:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['json'] = nil

      -- Create an autocommand group for linting
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })

      -- Set up autocommands to trigger linting
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only lint modifiable buffers to avoid unnecessary noise
          if vim.opt_local.modifiable:get() then
            lint.try_lint() -- Run the linter
          end
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
