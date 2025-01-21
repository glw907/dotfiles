-- ============================================================================
-- NVIM-CMP PLUGIN CONFIGURATION
--
-- Nvim-cmp is a highly extensible autocompletion plugin for Neovim. This
-- configuration sets up autocompletion for various sources, integrates with
-- LuaSnip for snippet support, and provides intuitive key mappings for
-- seamless code editing.
--
-- For more information, see:
--    https://github.com/hrsh7th/nvim-cmp
-- ============================================================================

return {
  { -- Main autocompletion plugin
    'hrsh7th/nvim-cmp',

    -- Load the plugin when entering Insert mode
    event = 'InsertEnter',

    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',

        -- Build step required for regex support in snippets
        -- Disabled on Windows environments without `make`
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),

        dependencies = {
          -- Optional: Predefined snippets for various languages
          -- Uncomment to enable
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      -- Adds LuaSnip as a completion source
      'saadparwaiz1/cmp_luasnip',

      -- Additional completion sources
      'hrsh7th/cmp-nvim-lsp', -- LSP completion
      'hrsh7th/cmp-path', -- Path completion
    },

    config = function()
      -- Load required modules
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      -- Setup LuaSnip
      luasnip.config.setup {}

      -- Configure nvim-cmp
      cmp.setup {
        -- Snippet expansion using LuaSnip
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Completion behavior
        completion = { completeopt = 'menu,menuone,noinsert' },

        -- Key mappings for completion
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(), -- Next item
          ['<C-p>'] = cmp.mapping.select_prev_item(), -- Previous item
          ['<C-b>'] = cmp.mapping.scroll_docs(-4), -- Scroll docs back
          ['<C-f>'] = cmp.mapping.scroll_docs(4), -- Scroll docs forward
          ['<C-y>'] = cmp.mapping.confirm { select = true }, -- Confirm selection

          -- Manually trigger completion
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Navigate snippet expansion
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),
        },

        -- Define completion sources
        sources = {
          {
            name = 'lazydev',
            -- Exclude LuaLS completions as per lazydev's recommendation
            group_index = 0,
          },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
