-- ============================================================================
-- INDENT-BLANKLINE.NVIM PLUGIN CONFIGURATION
--
-- This plugin adds indentation guides, including on blank lines, to improve
-- code readability. It is particularly useful for understanding nested code
-- structures in files with significant indentation (e.g., Python, YAML).
--
-- For more information, see:
--    https://github.com/lukas-reineke/indent-blankline.nvim
-- ============================================================================

return {
  { -- Indentation guides for Neovim
    'lukas-reineke/indent-blankline.nvim',

    -- Specify the main module for the plugin
    main = 'ibl',

    -- Plugin options (default settings in this case)
    opts = {},
  },
}
-- vim: ts=2 sts=2 sw=2 et
