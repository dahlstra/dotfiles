vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      --[[
      -- Requirements:
      -- 1. tar and curl in your path
      -- 2. tree-sitter-cli installed via package manager (not npm)
      -- 3. A C compiler in your path
      --]]
      require("plugin-loader").load_and_setup_once(
        "nvim-treesitter",
        { "https://github.com/nvim-treesitter/nvim-treesitter" },
        function()
          local ts = require("nvim-treesitter")
          local ok, msg = pcall(ts.install, { "c", "rust", "markdown" })
          if not ok then
            vim.notify(msg, vim.log.levels.ERROR)
          end
        end
      )
    end, 100)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c" },
  callback = function(args)
    vim.schedule(function()
      vim.treesitter.start(args.buf, "c")
    end)
  end,
})
