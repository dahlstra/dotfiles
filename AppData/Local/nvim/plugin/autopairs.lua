vim.api.nvim_create_autocmd("InsertEnter", {
  once = true,
  callback = function()
    require("plugin-loader").load_and_setup_once("nvim-autopairs", { "https://github.com/windwp/nvim-autopairs" }, function()
      require("nvim-autopairs").setup({})
    end)
  end,
})
