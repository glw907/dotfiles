-- ============================================================================
-- NEOVIM CONFIGURATION
--
-- This file serves as the main entry point for configuring Neovim.
-- It sets global settings, initializes keymaps, and loads plugin-related
-- configurations. Modules are organized for clarity and ease of maintenance.
-- ============================================================================

-- Set <space> as the leader key (must be set before plugins load)
-- See `:help mapleader`
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you use a Nerd Font in your terminal
vim.g.have_nerd_font = false

-- Load configuration modules
require 'options' -- General settings
require 'keymaps' -- Key mappings
require 'lazy-bootstrap' -- Plugin manager setup
require 'lazy-plugins' -- Plugin configurations

-- Modeline: Ensure consistent formatting
-- vim: ts=2 sts=2 sw=2 et
