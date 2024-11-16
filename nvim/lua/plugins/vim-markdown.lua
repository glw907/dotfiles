-- ============================================================================
-- VIM-MARKDOWN PLUGIN CONFIGURATION
--
-- Vim-markdown provides enhanced syntax highlighting and text objects for
-- Markdown files. It includes features like folding, table highlighting, and
-- fenced code block support.
--
-- This configuration disables line folding by default.
--
-- For more information, see:
--    https://github.com/preservim/vim-markdown
-- ============================================================================

return {
  {
    'preservim/vim-markdown', -- Markdown support for Neovim

    -- Load for Markdown filetypes only
    ft = { 'markdown' },

    -- Plugin options and settings
    config = function()
      -- Disable line folding by default
      vim.g.vim_markdown_folding_disabled = 1

      -- Additional plugin settings can be added here:
      -- vim.g.vim_markdown_conceal = 0 -- Disable conceal for Markdown files
      -- vim.g.vim_markdown_folding_level = 6 -- Maximum folding level
      -- vim.g.vim_markdown_folding_style = 'expr' -- Folding method ('expr', 'syntax', 'marker')
      -- vim.g.vim_markdown_folding_style_pythonic = 0 -- Use standard folding markers

      -- vim.g.vim_markdown_conceal = 0 -- Disable conceal for Markdown
      -- vim.g.vim_markdown_conceal_code_blocks = 0 -- Do not conceal fenced code blocks

      -- vim.g.vim_markdown_auto_insert_bullets = 1 -- Automatically insert bullets in lists
      -- vim.g.vim_markdown_new_list_item_indent = 2 -- Indent level for new list items
      -- vim.g.vim_markdown_edit_url_in_place = 0 -- Allow editing URLs inline

      -- vim.g.vim_markdown_frontmatter = 1 -- Highlight YAML frontmatter
      -- vim.g.vim_markdown_strikethrough = 1 -- Enable strikethrough for `~~text~~`
      -- vim.g.vim_markdown_math = 1 -- Highlight math blocks
      -- vim.g.vim_markdown_toc_autofit = 1 -- Auto-fit the table of contents window
      -- vim.g.vim_markdown_no_extensions_in_markdown = 1 -- Disable `.md` file extensions

      -- vim.g.vim_markdown_table_auto_align = 1 -- Automatically align tables
      -- vim.g.vim_markdown_table_no_mappings = 0 -- Enable default table key mappings
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
