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

vim.keymap.set("n", "<leader>ff", picker.files, { desc = "find files" })
vim.keymap.set("n", "<leader>fs", picker.smart, { desc = "smart search" })
vim.keymap.set("n", "<leader>fg", picker.grep, { desc = "live grep" })
vim.keymap.set("n", "<leader>fb", picker.buffers, { desc = "buffers" })
vim.keymap.set("n", "<leader>/", picker.lines, { desc = "buffer lines" })
vim.keymap.set("n", "<leader>fr", picker.recent, { desc = "recent files" })
vim.keymap.set("n", "<leader>d", picker.diagnostics, { desc = "diagnostics" })
vim.keymap.set("n", "<leader>gs", picker.lsp_symbols, { desc = "workspace symbols" })
vim.keymap.set("n", "<leader>gr", picker.lsp_references, { desc = "references" })
vim.keymap.set({ "n", "x" }, "<leader>fw", picker.grep_word, { desc = "visual selection or word" })
vim.keymap.set("n", "<leader>?h", picker.help, { desc = "help pages" })
vim.keymap.set("n", "<leader>?c", picker.commands, { desc = "commands" })
vim.keymap.set("n", "<leader>?k", picker.keymaps, { desc = "keymaps" })
vim.keymap.set("n", "<leader>fm", picker.marks, { desc = "marks" })
vim.keymap.set("n", "<leader>fn", picker.notifications, { desc = "notifications" })

vim.api.nvim_create_autocmd("LspProgress", {
  ---@diagnostic disable-next-line: undefined-doc-name
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
