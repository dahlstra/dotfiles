vim.pack.add({
  {
    src = "https://github.com/catppuccin/nvim",
    name = "catppuccin-nvim",
  },
})

vim.cmd("colorscheme catppuccin")

vim.o.background = "dark"
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#89b4fa" })
