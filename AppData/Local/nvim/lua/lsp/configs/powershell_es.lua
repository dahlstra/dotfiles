return {
  name = "powershell_es",
  settings = {
    -- For some reason it couldn't find this on its own so I had to specify it
    bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
  },
}
