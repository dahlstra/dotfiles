-- Search highlight
vim.keymap.set("n", "<ESC>", "<cmd>nohl<CR>", { desc = "Remove search highlights in normal mode" })

-- Buffers
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer", })
vim.keymap.set("n", "<leader>bw", "<cmd>w<CR>", { desc = "Save buffer", })
vim.keymap.set("n", "<leader>bW", "<cmd>wa<CR>", { desc = "Save all buffers", })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer, unless unsaved", })
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Delete buffer, no saving", })

-- Center the cursor while moving around
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "n", "nzz")
vim.keymap.set("n", "N", "Nzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")
vim.keymap.set("n", "g*", "g*zz")
vim.keymap.set("n", "g#", "g#zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "move down in buffer with cursor centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "move up in buffer with cursor centered" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Splitting & resizing
vim.keymap.set("n", "<leader>sv", "<CMD>vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", "<CMD>split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")

-- Indentation
vim.keymap.set("v", ">", ">gv")
vim.keymap.set("v", "<", "<gv")

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Yank/Paste/Selection
vim.keymap.set("v", "<leader>p", [["_dP]], { desc = "Paste without replacing clipboard content" } )
vim.keymap.set({ "v", "n" }, "<leader>d", [["_d]], { desc = "Delete without replacing clipboard content" })
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "<leader>sa", "ggVG", { desc = "Select all", })
vim.keymap.set("n", "<leader>y", "0y$", { desc = "Yank line without newline", })

-- Current directory and file information
vim.keymap.set("n", "<leader>wd", function()
    print(vim.fn.getcwd())
end, {
    desc = "Print working directory",
})

vim.keymap.set("n", "<leader>wf", function()
    print(vim.fn.expand("%:p"))
end, {
    desc = "Print current file",
})
