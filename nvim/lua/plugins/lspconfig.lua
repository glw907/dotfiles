-- ============================================================================
-- NVIM LSP CONFIGURATION
--
-- This configuration sets up the Language Server Protocol (LSP) integration in
-- Neovim. It leverages Mason for automated installation of LSP servers, tools,
-- and plugins like Fidget for status updates and LazyDev for Lua-specific features.
--
-- Key features of LSP include:
--  - Go to definition, references, and type definitions.
--  - Autocompletion and inline diagnostics.
--  - Workspace and document symbol searches.
--
-- For more information, see:
--    https://github.com/neovim/nvim-lspconfig
-- ============================================================================

return {
  { -- Configure Lua-specific LSP for Neovim runtime and plugins
    'folke/lazydev.nvim',
    ft = 'lua', -- Load only for Lua files
    opts = {
      library = {
        -- Load luvit types when `vim.uv` is detected
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },

  { -- Main LSP configuration plugin
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Tools for LSP and related dependencies
      { 'williamboman/mason.nvim', config = true }, -- Install LSP servers
      'williamboman/mason-lspconfig.nvim', -- Manage LSP installations
      'WhoIsSethDaniel/mason-tool-installer.nvim', -- Additional Mason utilities
      { 'j-hui/fidget.nvim', opts = {} }, -- LSP status updates
      'hrsh7th/cmp-nvim-lsp', -- nvim-cmp integration for autocompletion
    },
    config = function()
      -- ========================================================================
      -- BRIEF OVERVIEW: WHAT IS LSP?
      --
      -- The Language Server Protocol (LSP) standardizes communication between
      -- editors and language-specific tools (servers). LSP servers provide
      -- features like:
      --  - Go to definition, references, and type definitions.
      --  - Symbol searches (workspace or document).
      --  - Inline diagnostics and autocompletion.
      --
      -- Neovim acts as the LSP client, interacting with external language
      -- servers like `lua_ls`, `rust_analyzer`, etc.
      -- ========================================================================

      -- Auto-command to set up key mappings and functionality when an LSP attaches
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Define LSP-specific key mappings
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- Highlight references and toggle inlay hints
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      -- Define additional LSP capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Configure LSP servers
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
            },
          },
        },
      }

      -- Install and configure LSP servers with Mason
      require('mason').setup()
      require('mason-tool-installer').setup { ensure_installed = { 'stylua' } }
      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
