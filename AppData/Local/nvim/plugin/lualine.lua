vim.pack.add({
  "https://github.com/nvim-tree/nvim-web-devicons",
  "https://github.com/nvim-lualine/lualine.nvim",
})

require("lualine").setup({
  sections = {
    lualine_c = {
      {
        function()
          return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
        end,
        icon = "",
        color = "Directory",
      },
      "filename",
    },
  },
})
