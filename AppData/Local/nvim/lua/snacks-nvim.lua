vim.pack.add({
  "https://github.com/folke/snacks.nvim",
})

require("snacks").setup({
  quickfile = {
    enabled = true,
  },
  lazygit = {
    enabled = true,
  },
  picker = {
    enabled = true,
  },
  notifier = {
    enabled = true,
    timeout = 5000,
  },
  statuscolumn = {
    enabled = true,
  },
  words = {
    enabled = true,
  },
})

---@diagnostic disable: undefined-global
local picker = Snacks.picker

vim.keymap.set("n", "<leader>ff", picker.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fs", picker.smart, { desc = "Smart search" })
vim.keymap.set("n", "<leader>fg", picker.grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", picker.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>/", picker.lines, { desc = "Buffer lines" })
vim.keymap.set("n", "<leader>fr", picker.recent, { desc = "Recent files" })
vim.keymap.set("n", "<leader>d", picker.diagnostics, { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>gs", picker.lsp_symbols, { desc = "Workspace symbols" })
vim.keymap.set("n", "<leader>gr", picker.lsp_references, { desc = "References" })
vim.keymap.set({ "n", "x" }, "<leader>fw", picker.grep_word, { desc = "Visual selection or word" })
vim.keymap.set("n", "<leader>?h", picker.help, { desc = "Help pages" })
vim.keymap.set("n", "<leader>?c", picker.commands, { desc = "Commands" })
vim.keymap.set("n", "<leader>?k", picker.keymaps, { desc = "Keymaps" })
vim.keymap.set("n", "<leader>fm", picker.marks, { desc = "Marks" })
vim.keymap.set("n", "<leader>fn", picker.notifications, { desc = "Notifications" })

vim.api.nvim_create_autocmd("LspProgress", {
  callback = function(ev)
    local spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
    vim.notify(vim.lsp.status(), vim.log.levels.INFO, {
      id = "lsp_progress",
      title = vim.lsp.get_client_by_id(ev.data.client_id).name,
      opts = function(notif)
        notif.icon = ev.data.params.value.kind == "end" and " "
          or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
      end,
    })
  end,
})
