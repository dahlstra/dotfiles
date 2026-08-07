local M = {}
local loaded = {}

function M.load_and_setup_once(name, spec, setup)
  if loaded[name] then
    return
  end

  vim.pack.add(spec)
  if setup then
    setup()
  end

  loaded[name] = true
end

return M
