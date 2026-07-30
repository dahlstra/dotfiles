local function lualine_setup()
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
end

-- Wait 50ms to load lualine since we don't need it before the UI loads
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      require("plugin-loader").load_once("lualine", {
        "https://github.com/nvim-tree/nvim-web-devicons",
        "https://github.com/nvim-lualine/lualine.nvim",
      }, lualine_setup)
    end, 50)
  end,
})
