vim.keymap.set("n", "-", function()
  require("plugin-loader").load_and_setup_once("oil", { "https://github.com/stevearc/oil.nvim" }, function()
    require("oil").setup()
  end)

  vim.cmd.Oil()
end, { desc = "Open parent directory" })
