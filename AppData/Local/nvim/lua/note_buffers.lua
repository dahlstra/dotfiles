local notes_dir = vim.fn.stdpath("data") .. "/notes/"
vim.fn.mkdir(notes_dir, "p")

vim.keymap.set("n", "<leader>nn", function()
  vim.cmd("edit " .. notes_dir .. os.date("%Y-%m-%d_%H-%M-%S") .. ".md")
end, { desc = "New note file" })

vim.keymap.set("n", "<leader>no", function()
  local files = vim.fn.readdir(notes_dir)
  local items = {}
  for _, f in ipairs(files) do
    table.insert(items, { file = notes_dir .. f, name = f })
  end

  vim.ui.select(items, {
    prompt = "Note files",
    format_item = function(item)
      return item.name
    end,
  }, function(choice)
    if choice then
      vim.cmd("edit " .. choice.file)
    end
  end)
end, { desc = "Open note file" })
