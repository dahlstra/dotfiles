vim.g.mapleader = " "
vim.g.maplocalleader = " "

local function started_without_arguments()
  return vim.fn.argc() == 0
    and vim.fn.line2byte("$") == -1 -- empty initial buffer
    and not vim.g.started_by_firenvim
end

-- Don't bother bringing up our start screen if we are opening a file directly
if started_without_arguments() then
  require("alpha-nvim")
end

require("general-options")
require("general-keymaps")
require("autocommands")
require("themes")
require("selection_expand_shrink")
require("note_buffers")
require("lsp.lsp_setup")
require("snacks-nvim")
