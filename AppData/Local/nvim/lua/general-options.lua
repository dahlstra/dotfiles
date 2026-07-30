-- Basic settings
vim.g.have_nerd_font = true
vim.o.scrolloff = 4
vim.o.sidescrolloff = 8
vim.o.number = true
vim.o.relativenumber = true
vim.o.linebreak = true

-- Indentation
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.inccommand = "split"
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.breakindent = true
vim.o.showbreak = "↪ "
vim.o.grepprg = "rg --vimgrep"   -- Use ripgrep if available
vim.o.grepformat = "%f:%l:%c:%m" -- filename, line number, column, content

-- Search settings
vim.o.ignorecase = true -- Case insensitive search
vim.o.smartcase = true  -- Case sensitive if uppercase in search
vim.o.hlsearch = true   -- Don't highlight search results
vim.o.incsearch = true  -- Show matches as you type

-- Visual settings
vim.o.termguicolors = true        -- Enable 24-bit colors
vim.o.signcolumn = "yes"          -- Always show sign column
vim.o.showmatch = true            -- Highlight matching brackets
vim.o.matchtime = 1               -- How long to show matching bracket
vim.o.cmdheight = 1               -- Command line height
vim.o.showmode = false            -- Don't show mode in command line
vim.o.pumheight = 10              -- Popup menu height
vim.o.pumblend = 15               -- Popup menu transparency
vim.o.pumborder = "rounded"       -- Popup menu border
vim.o.winblend = 0                -- Floating window transparency
vim.o.winborder = "rounded"       -- Floating window border
vim.o.conceallevel = 0            -- Don't hide markup
vim.o.concealcursor = ""          -- Don't hide cursor line markup
vim.o.redrawtime = 10000          -- Timeout for syntax highlighting redraws
vim.o.synmaxcol = 300             -- Syntax highlighting limit
vim.o.maxmempattern = 20000       -- Max memory for pattern matching
vim.opt.fillchars = { eob = " " } -- Hide ~ on empty lines

-- Create undo directory if it doesn't exist
local undodir = "~/.local/share/nvim/undodir"
vim.o.undodir = vim.fn.expand(undodir)
local undodir_path = vim.fn.expand(undodir)
if vim.fn.isdirectory(undodir_path) == 0 then
   vim.fn.mkdir(undodir_path, "p")
end

-- File handling
vim.o.backup = false                         -- Don't create backup files
vim.o.writebackup = false                    -- Don't create backup before writing
vim.o.swapfile = false                       -- Don't create swap files
vim.o.undofile = true                        -- Persistent undo
vim.o.updatetime = 200                       -- Faster completion
vim.o.timeoutlen = 300                       -- Key timeout duration
vim.o.ttimeoutlen = 0                        -- Key code timeout
vim.o.autoread = true                        -- Auto reload files changed outside vim
vim.o.autowrite = false                      -- Don't auto save
vim.opt.diffopt:append("vertical")           -- Vertical diff splits
vim.opt.diffopt:append("algorithm:patience") -- Better diff algorithm
vim.opt.diffopt:append("linematch:60")       -- Better diff highlighting (smart line matching)

-- Behavior settings
-- Schedule after UiEnter to reduce startup time
vim.schedule(function() vim.o.clipboard = "unnamedplus" end)
vim.opt.path:append("**")            -- include subdirectories in search
vim.o.hidden = true                  -- Allow hidden buffers
vim.o.errorbells = false             -- No error bells
vim.o.backspace = "indent,eol,start" -- Better backspace behavior
vim.o.autochdir = false              -- Don't auto change directory
vim.o.selection = "inclusive"        -- Selection behavior
vim.o.mouse = "a"                    -- Enable mouse support
vim.o.modifiable = true              -- Allow buffer modifications
vim.o.encoding = "UTF-8"             -- Set encoding
vim.o.wildmenu = true                -- Enable command line completion menu
vim.o.wildmode = "longest:full,full" -- Completion mode for command line
vim.o.wildignorecase = true          -- Case-insensitive tab completion on commands
vim.o.confirm = true                 -- Ask if we want to save before exiting dirty files
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Folding settings
vim.o.foldmethod = "manual"

-- Split behavior
vim.o.splitbelow = true -- Horizontal splits go below
vim.o.splitright = true -- Vertical splits go right

-- Disable netrw because we are using Oil
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Set the shell
if vim.fn.has("win32") == 1 then
   vim.o.shell = "pwsh.exe"
end

-- Diagnostic Config & Keymaps
--  See `:help vim.diagnostic.Opts`
vim.diagnostic.config {
   update_in_insert = false,
   severity_sort = true,
   float = { border = "rounded", source = "if_many" },
   underline = { severity = { min = vim.diagnostic.severity.WARN } },

   -- Can switch between these as you prefer
   virtual_text = true,    -- Text shows up at the end of the line
   virtual_lines = false,  -- Text shows up underneath the line, with virtual lines

   -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
   jump = {
      on_jump = function(_, bufnr)
         vim.diagnostic.open_float {
            bufnr = bufnr,
            scope = "cursor",
            focus = false,
         }
      end,
   },
}

vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
