local M = {}

local selection_history = setmetatable({}, {
  __index = function(t, k)
    t[k] = {}
    return t[k]
  end,
})

local function get_selection_range()
  local mode = vim.fn.mode()
  if mode:match("^[vV\22]") then
    local s = vim.fn.getpos("v")
    local e = vim.fn.getpos(".")
    local sr, sc, er, ec = s[2] - 1, s[3] - 1, e[2] - 1, e[3] - 1
    if er < sr or (er == sr and ec < sc) then
      sr, sc, er, ec = er, ec, sr, sc
    end
    return sr, sc, er, ec + 1
  else
    local cur = vim.api.nvim_win_get_cursor(0)
    local row, col = cur[1] - 1, cur[2]
    return row, col, row, col + 1
  end
end

-- Treesitter"s end_row/end_col are exclusive
local function normalize_end(buf, er, ec)
  if ec == 0 then
    er = math.max(er - 1, 0)
    local line = vim.api.nvim_buf_get_lines(buf, er, er + 1, false)[1] or ""
    ec = #line
  end
  return er, ec
end

-- Puts the window into visual mode selecting [sr,sc] .. [er,ec) (ec exclusive).
local function select_range(buf, sr, sc, er, ec)
  er, ec = normalize_end(buf, er, ec)
  if vim.fn.mode() ~= "n" then
    vim.cmd("normal! \27")
  end
  vim.api.nvim_win_set_cursor(0, { sr + 1, sc })
  vim.cmd("normal! v")
  local last_col = math.max(ec - 1, 0)
  vim.api.nvim_win_set_cursor(0, { er + 1, last_col })
end

local function ranges_equal(a, b)
  return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
end

-- True if `outer` fully contains `inner` (endpoints inclusive-equal allowed).
local function range_contains(outer, inner)
  local osr, osc, oer, oec = outer[1], outer[2], outer[3], outer[4]
  local isr, isc, ier, iec = inner[1], inner[2], inner[3], inner[4]
  local starts_ok = (osr < isr) or (osr == isr and osc <= isc)
  local ends_ok = (oer > ier) or (oer == ier and oec >= iec)

  return starts_ok and ends_ok
end

function M.expand()
  local buf = vim.api.nvim_get_current_buf()
  local sr, sc, er, ec = get_selection_range()
  local current = { sr, sc, er, ec }

  local ok, node = pcall(vim.treesitter.get_node, { pos = { sr, sc } })
  if not ok or not node then
    return
  end

  -- Walk up parents until we find one that strictly contains the current selection
  local target
  while node do
    local nsr, nsc, ner, nec = node:range()
    local nrange = { nsr, nsc, ner, nec }
    if range_contains(nrange, current) and not ranges_equal(nrange, current) then
      target = nrange
      break
    end
    node = node:parent()
  end

  if not target then
    return
  end

  table.insert(selection_history[buf], current)
  select_range(buf, target[1], target[2], target[3], target[4])
end

function M.shrink()
  local buf = vim.api.nvim_get_current_buf()
  local history = selection_history[buf]
  if #history == 0 then
    return
  end
  local prev = table.remove(history)
  select_range(buf, prev[1], prev[2], prev[3], prev[4])
end

-- Reset history (handy if the buffer changes underneath the selection)
vim.api.nvim_create_autocmd({ "InsertEnter", "BufLeave" }, {
  callback = function(args)
    selection_history[args.buf] = {}
  end,
})

vim.keymap.set({ "n", "x" }, "<A-[>", M.expand, { desc = "Expand selection to next larger syntax node" })
vim.keymap.set("x", "<A-]>", M.shrink, { desc = "Shrink selection to previous syntax node" })

return M
