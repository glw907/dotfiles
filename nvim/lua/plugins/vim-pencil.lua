-- ============================================================================
-- VIM-PENCIL PLUGIN CONFIGURATION
--
-- Provides an enhanced writing experience for Markdown, text, and similar
-- filetypes. Automatically enables soft wrapping and improves alignment for
-- ordered and unordered lists, while ensuring paragraphs do not indent when
-- wrapped.
--
-- For more information, see:
--    https://github.com/reedes/vim-pencil
-- ============================================================================

return {
  {
    'reedes/vim-pencil', -- Lightweight plugin for writing workflows

    -- Load for specific filetypes
    ft = { 'markdown', 'text', 'gitcommit' },

    -- Plugin options and settings
    config = function()
      -- Automatically enable PencilSoft for supported filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit" },
        callback = function()
          vim.cmd("PencilSoft")
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
