vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      require("plugin-loader").load_and_setup_once("snacks", { "https://github.com/folke/snacks.nvim" }, function()
        require("snacks").setup({
          quickfile = {
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
        vim.keymap.set("n", "<leader>gs", function()
          -- The plugin can get confused if you have unsaved changes
          vim.cmd("w")
          picker.lsp_symbols()
        end, { desc = "Symbols" })
        vim.keymap.set("n", "<leader>gr", picker.lsp_references, { desc = "References" })
        vim.keymap.set({ "n", "x" }, "<leader>fw", picker.grep_word, { desc = "Visual selection or word" })
        vim.keymap.set("n", "<leader>?h", picker.help, { desc = "Help pages" })
        vim.keymap.set("n", "<leader>?c", picker.commands, { desc = "Commands" })
        vim.keymap.set("n", "<leader>?k", picker.keymaps, { desc = "Keymaps" })
        vim.keymap.set("n", "<leader>fm", picker.marks, { desc = "Marks" })
        vim.keymap.set("n", "<leader>fn", picker.notifications, { desc = "Notifications" })
      end)
    end)
  end,
})
