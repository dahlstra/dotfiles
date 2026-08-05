vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      require("plugin-loader").load_and_setup_once("mini", { "https://github.com/nvim-mini/mini.nvim" }, function()
        require("mini.surround").setup({})
      end)
    end)
  end,
})
