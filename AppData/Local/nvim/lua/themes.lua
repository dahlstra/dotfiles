vim.pack.add({
  {
    src = "https://github.com/catppuccin/nvim",
    name = "catppuccin-nvim",
  },
})

local utils = require("utils.highlights")

vim.cmd("colorscheme catppuccin-mocha")
utils.clear_hl_background("Normal")
utils.clear_hl_background("NormalFloat")
utils.clear_hl_background("NormalNC")
utils.clear_hl_background("Pmenu")
utils.clear_hl_background("PmenuBorder")
utils.clear_hl_background("FloatTitle")
utils.clear_hl_background("FloatFooter")
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#89b4fa" })
