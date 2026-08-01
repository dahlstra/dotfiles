vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    require("plugin-loader").load_once("mini", { "https://github.com/nvim-mini/mini.nvim" }, function()
      require("mini.surround").setup({})
    end)
  end,
})
