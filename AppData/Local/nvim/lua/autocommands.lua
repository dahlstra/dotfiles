local big_file_group = vim.api.nvim_create_augroup("BifFileCheckGroup", {})
vim.api.nvim_create_autocmd("BufReadPre", {
  group = big_file_group,
  callback = function(args)
    local max_size = 500000
    local stat = vim.uv.fs_stat(args.file)

    -- Turning off stuff that we obviously won't be using for huge files
    if stat and stat.size > max_size then
      for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
        vim.api.nvim_set_option_value("wrap", false, { win = win })
        vim.api.nvim_set_option_value("linebreak", false, { win = win })
        vim.api.nvim_set_option_value("breakindent", false, { win = win })
        vim.api.nvim_set_option_value("conceallevel", 0, { win = win })
        vim.api.nvim_set_option_value("relativenumber", false, { win = win })
      end

      vim.b[args.buf].large_buf = true
    end
  end,
})

-- Restore last cursor position when reopening a file
local last_cursor_group = vim.api.nvim_create_augroup("LastCursorGroup", {})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = last_cursor_group,
  callback = function(args)
    -- big file? forget it
    if vim.b[args.buf].large_buf then
      return
    end

    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
      vim.schedule(function()
        vim.cmd.normal({ "zz", bang = true })
      end)
    end
  end,
})

-- Highlight yanked text for 200ms
local highlight_yank_group = vim.api.nvim_create_augroup("HighlightYank", {})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_yank_group,
  pattern = "*",
  callback = function()
    vim.hl.on_yank({
      higroup = "IncSearch",
      timeout = 200,
    })
  end,
})

-- Specific indentation/width for files read more like prose
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "markdown",
    "text",
    "gitcommit",
  },
  callback = function(args)
    -- Don't bother for big files
    if vim.b[args.buf].large_buf then
      return
    end

    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.textwidth = 150
    vim.opt_local.showbreak = ""
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "lua",
  },
  callback = function()
    vim.o.shiftwidth = 3
    vim.o.tabstop = 3
  end,
})

-- Toggle relative line numbers off when we are in insert mode
local numbertoggle_group = vim.api.nvim_create_augroup("numbertoggle", {})
vim.api.nvim_create_autocmd({
  "BufEnter",
  "FocusGained",
  "InsertLeave",
  "CmdlineLeave",
  "WinEnter",
}, {
  pattern = "*",
  group = numbertoggle_group,
  callback = function(args)
    -- Don't care about relative line numbers for huge files
    if vim.b[args.buf].large_buf then
      return
    end

    if vim.o.nu and vim.api.nvim_get_mode().mode ~= "i" then
      vim.opt.relativenumber = true
    end
  end,
})
vim.api.nvim_create_autocmd({
  "BufLeave",
  "FocusLost",
  "InsertEnter",
  "CmdlineEnter",
  "WinLeave",
}, {
  pattern = "*",
  group = numbertoggle_group,
  callback = function(args)
    -- Don't care about relative line numbers for huge files
    if vim.b[args.buf].large_buf then
      return
    end

    if vim.o.nu then
      vim.opt.relativenumber = false
      -- Conditional taken from https://github.com/rockyzhang24/dotfiles/commit/03dd14b5d43f812661b88c4660c03d714132abcf
      -- Workaround for https://github.com/neovim/neovim/issues/32068
      if not vim.tbl_contains({ "@", "-" }, vim.v.event.cmdtype) then
        vim.cmd("redraw")
      end
    end
  end,
})
