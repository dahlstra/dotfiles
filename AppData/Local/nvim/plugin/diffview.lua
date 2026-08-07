vim.keymap.set("n", "<leader>Gdo", function()
  require("plugin-loader").load_and_setup_once("diffview", { "https://github.com/sindrets/diffview.nvim" })
  vim.cmd("DiffviewOpen")
end, { desc = "Open Git diff viewer" })

vim.keymap.set("n", "<leader>Gdq", function()
  require("plugin-loader").load_and_setup_once("diffview", { "https://github.com/sindrets/diffview.nvim" })
  vim.cmd("DiffviewClose")
end, { desc = "Quit Git diff viewer" })
