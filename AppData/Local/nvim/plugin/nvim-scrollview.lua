vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      require("plugin-loader").load_and_setup_once(
        "nvim-scrollview",
        { "https://github.com/dstein64/nvim-scrollview" },
        function()
          require("scrollview").setup({
            excluded_filetypes = { "oil", "alpha" },
            hover = true,
            current_only = true,
            diagnostics_severities = { vim.diagnostic.severity.ERROR },
          })
        end
      )
    end, 100)
  end,
})
