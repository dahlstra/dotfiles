-- We don't need to load this immediately, so we'll wait 250ms
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      require("plugin-loader").load_once("mason", {
        "https://github.com/mason-org/mason.nvim",
      }, function()
        require("mason").setup()
      end)
    end, 250)
  end,
})
