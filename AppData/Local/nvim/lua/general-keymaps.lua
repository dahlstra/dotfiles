-- Search highlight
vim.keymap.set("n", "<ESC>", "<cmd>nohl<CR>", { desc = "Remove search highlights in normal mode" })

-- Easy line beginning and end
vim.keymap.set({ "n", "v" }, "<A-l>", "$", { desc = "Move to end of the line" })
vim.keymap.set({ "n", "v" }, "<A-h>", "0", { desc = "Move to beginning of the line" })

-- Buffers
vim.keymap.set("n", "<leader>bn", "<cmd>enew<CR>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer, unless unsaved" })
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete!<CR>", { desc = "Delete buffer, no saving" })

-- Center the cursor while moving around
vim.keymap.set("n", "G", "Gzz", { desc = "Go to end of the buffer, centering around cursor" })
vim.keymap.set("n", "N", "Nzz", { desc = "Previous search result, centering around cursor" })
vim.keymap.set("n", "n", "nzz", { desc = "Next search result, centering around cursor" })
vim.keymap.set("n", "*", "*zz", { desc = "Next occurence of word under cursor, centering around cursor" })
vim.keymap.set("n", "#", "#zz", { desc = "Previous occurence of word under cursor, centering around cursor" })
vim.keymap.set("n", "g*", "g*zz", { desc = "Next occurence of word under cursor, centering around cursor" })
vim.keymap.set("n", "g#", "g#zz", { desc = "Previous occurence of word under cursor, centering around cursor" })

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
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("", "<C-c>", "y")
vim.keymap.set("n", "<leader>sa", "ggVG", { desc = "Select all" })
vim.keymap.set("n", "<leader>y", "0y$", { desc = "Yank line without newline" })

vim.keymap.set("n", "<leader>m", "g<", { desc = "Message history" })

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

local function show_messages()
    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(
        buf,
        0,
        -1,
        false,
        vim.split(vim.fn.execute("messages"), "\n", { plain = true })
    )

    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = false

    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.7)

    vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = "rounded",
        title = " Message History ",
        title_pos = "center",
    })

    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf })
end

vim.keymap.set("n", "<leader>m", show_messages, {
    desc = "Show message history",
})
