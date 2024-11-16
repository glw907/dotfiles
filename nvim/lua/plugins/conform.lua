-- ============================================================================
-- CONFORM.NVIM PLUGIN CONFIGURATION
--
-- Conform.nvim is an autoformatting plugin that provides seamless formatting
-- for various file types. It supports both asynchronous formatting and
-- integration with LSP formatters. This configuration includes on-save
-- formatting and custom formatter settings per filetype.
--
-- For more information, see:
--    https://github.com/stevearc/conform.nvim
-- ============================================================================

return {
  { -- Main autoformatting plugin
    'stevearc/conform.nvim',

    -- Trigger formatting before saving the buffer
    event = { 'BufWritePre' },

    -- Add the `ConformInfo` command for plugin debugging and diagnostics
    cmd = { 'ConformInfo' },

    -- Define key mappings
    keys = {
      {
        '<leader>f',
        function()
          -- Format the buffer asynchronously
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '', -- Available in all modes
        desc = '[F]ormat buffer',
      },
    },

    opts = {
      -- Disable notifications for formatting errors
      notify_on_error = false,

      -- Configure format-on-save behavior
      format_on_save = function(bufnr)
        -- Exclude specific filetypes from LSP fallback formatting
        -- Languages without well-standardized styles can be added here
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = 'never' -- Never use LSP formatting for these filetypes
        else
          lsp_format_opt = 'fallback' -- Use LSP fallback formatting
        end

        return {
          timeout_ms = 500, -- Set timeout for formatting
          lsp_format = lsp_format_opt, -- Determine LSP format option
        }
      end,

      -- Define formatters by filetype
      formatters_by_ft = {
        lua = { 'stylua' }, -- Use `stylua` for Lua formatting

        -- Example: Multiple formatters for a single filetype
        -- python = { "isort", "black" },

        -- Example: Stop after the first available formatter
        -- javascript = { "prettierd", "prettier", stop_after_first = true },
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
