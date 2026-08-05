vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      require("plugin-loader").load_and_setup_once("lualine", {
        "https://github.com/nvim-tree/nvim-web-devicons",
        "https://github.com/nvim-lualine/lualine.nvim",
      }, function()
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
      end)
    end)
  end,
})
