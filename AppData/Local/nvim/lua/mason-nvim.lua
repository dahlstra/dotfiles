vim.pack.add({
  "https://github.com/mason-org/mason.nvim",
})

require("mason").setup({
  ensure_installed = { "lua_ls", "marksman", "powershell-editor-services" },
})
