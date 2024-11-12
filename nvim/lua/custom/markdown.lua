-- custom/markdown.lua

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    -- Markdown-specific indentation settings
    vim.opt_local.shiftwidth = 2 -- Set indentation level to 2 spaces
    vim.opt_local.tabstop = 2 -- Set tab width to 2 spaces
    vim.opt_local.expandtab = true -- Use spaces instead of tabs

    -- Disable folding for Markdown
    vim.opt_local.foldenable = false -- Disable folding

    -- Enable Vim Pencil for Markdown-specific soft-wrapping
    vim.cmd 'Pencil'

    -- Add a visual guide at 80 columns
    vim.opt_local.colorcolumn = '80' -- Display a guide at 80 columns

    -- Set wrapping to occur at 80 columns
    vim.opt_local.textwidth = 80 -- Set preferred text width to 80 columns
    vim.opt_local.wrap = true -- Enable soft wrapping
    vim.opt_local.linebreak = true -- Prevent breaking words in the middle
  end,
})

-- Return an empty table for Lazy compatibility
return {}
