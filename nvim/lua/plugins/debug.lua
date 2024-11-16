-- ============================================================================
-- DEBUG.LUA PLUGIN CONFIGURATION
--
-- This configuration demonstrates how to use the DAP (Debug Adapter Protocol)
-- plugin in Neovim for debugging code. It is primarily focused on configuring
-- the debugger for Go but can be extended to other languages.
--
-- Features include:
--   - Debugger setup with Mason for automatic installation of adapters.
--   - A user-friendly UI via nvim-dap-ui.
--   - Custom keybindings for debugging actions.
--
-- For more information, see:
--    https://github.com/mfussenegger/nvim-dap
-- ============================================================================

return {
  -- Main debugging plugin
  'mfussenegger/nvim-dap',

  -- Plugin dependencies
  dependencies = {
    'rcarriga/nvim-dap-ui', -- Beautiful debugger UI
    'nvim-neotest/nvim-nio', -- Required for nvim-dap-ui
    'williamboman/mason.nvim', -- Adapter manager
    'jay-babu/mason-nvim-dap.nvim', -- Installs debug adapters
    'leoluz/nvim-dap-go', -- Debugging configuration for Go
  },

  -- Keybindings for debugging actions
  keys = function(_, keys)
    local dap = require 'dap'
    local dapui = require 'dapui'

    return {
      { '<F5>', dap.continue, desc = 'Debug: Start/Continue' },
      { '<F1>', dap.step_into, desc = 'Debug: Step Into' },
      { '<F2>', dap.step_over, desc = 'Debug: Step Over' },
      { '<F3>', dap.step_out, desc = 'Debug: Step Out' },
      { '<leader>b', dap.toggle_breakpoint, desc = 'Debug: Toggle Breakpoint' },
      {
        '<leader>B',
        function()
          dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
        end,
        desc = 'Debug: Set Breakpoint',
      },
      { '<F7>', dapui.toggle, desc = 'Debug: Toggle Debugger UI' },
      unpack(keys),
    }
  end,

  -- Plugin configuration
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Setup Mason for managing debug adapters
    require('mason-nvim-dap').setup {
      automatic_installation = true, -- Automatically install adapters
      handlers = {}, -- Custom handlers can be added here
      ensure_installed = { 'delve' }, -- List of adapters to ensure are installed
    }

    -- Setup DAP UI
    -- For details, see `:help nvim-dap-ui`
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Configure DAP UI behavior
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Setup Go-specific debugging configuration
    require('dap-go').setup {
      delve = {
        detached = vim.fn.has 'win32' == 0, -- Use attached mode on Windows
      },
    }
  end,
}
-- vim: ts=2 sts=2 sw=2 et
