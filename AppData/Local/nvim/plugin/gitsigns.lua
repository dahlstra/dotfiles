vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      require("plugin-loader").load_and_setup_once("gitsigns", { "https://github.com/lewis6991/gitsigns.nvim" })
    end)
  end,
})
