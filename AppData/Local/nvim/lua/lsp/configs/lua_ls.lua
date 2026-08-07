return {
  name = "lua_ls",
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      completion = {
        callSnippet = "Disable",
        keywordSnippet = "Disable",
      },
    },
  },
}
