vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      require("plugin-loader").load_and_setup_once(
        "matchparen",
        { "https://github.com/monkoose/matchparen.nvim" },
        function()
          require("matchparen").setup({
            enabled = true,
          })
        end
      )
    end)
  end,
})
