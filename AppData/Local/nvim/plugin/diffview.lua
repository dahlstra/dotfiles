vim.keymap.set("n", "<C-A-g>", function()
  require("plugin-loader").load_and_setup_once("diffview", { "https://github.com/sindrets/diffview.nvim" })
  local lib = require("diffview.lib")
  local view = lib.get_current_view()
  if (view) then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end, { desc = "Toggle diff view" })
