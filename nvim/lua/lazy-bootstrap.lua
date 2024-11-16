-- ============================================================================
-- LAZY.NVIM BOOTSTRAP
--
-- This file ensures that the `lazy.nvim` plugin manager is installed and added
-- to the runtime path. If `lazy.nvim` is not installed, it is automatically
-- cloned from its GitHub repository.
--
-- For more information, see:
--    :help lazy.nvim.txt
--    https://github.com/folke/lazy.nvim
-- ============================================================================

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- vim: ts=2 sts=2 sw=2 et
