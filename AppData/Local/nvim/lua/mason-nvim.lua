vim.pack.add({
    {
        src = "https://github.com/mason-org/mason.nvim",
        name = "mason",
    },
})

require("mason").setup {
    ensure_installed = { "lua_ls", "marksman", "powershell-editor-services" }
}
