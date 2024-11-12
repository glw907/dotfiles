-- custom/plugins.lua

return {
  -- Enhanced Markdown editing with vim-markdown
  {
    'preservim/vim-markdown',
    config = function()
      vim.g.vim_markdown_folding_disabled = 1 -- Disable folding by default
    end,
  },

  -- Core Markdown support plugins
  { 'godlygeek/tabular' }, -- Alignment for tables in Markdown
  { 'dhruvasagar/vim-table-mode' }, -- Markdown table editing

  -- Vim Pencil for text-focused editing
  { 'reedes/vim-pencil' },
}
