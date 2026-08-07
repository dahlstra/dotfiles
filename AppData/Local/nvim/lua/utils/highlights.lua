local M = {}

function M.clear_hl_background(hlname)
  vim.api.nvim_set_hl(0, hlname, { bg = "none", update = true })
end

return M
