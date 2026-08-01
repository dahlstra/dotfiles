vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    require("plugin-loader").load_once("gitsigns", { "https://github.com/lewis6991/gitsigns.nvim" })
  end,
})
