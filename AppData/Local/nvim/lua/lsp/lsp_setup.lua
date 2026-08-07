vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      -- We need to make sure Mason gets loaded before our LSP stuff
      require("plugin-loader").load_and_setup_once(
        "mason-nvim",
        { "https://github.com/mason-org/mason.nvim" },
        function()
          require("mason").setup()
        end
      )

      require("plugin-loader").load_and_setup_once(
        "lsp-config",
        { "https://github.com/neovim/nvim-lspconfig" },
        function()
          vim.schedule(function()
            local clients = {}

            for _, file in ipairs(vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/lsp/configs")) do
              local config_name = file:gsub("%.lua$", "")
              local config = require("lsp/configs/" .. config_name)

              if config.settings then
                vim.lsp.config(config.name, { settings = config.settings })
              end

              table.insert(clients, config.name)
            end

            vim.lsp.enable(clients)

            vim.api.nvim_create_autocmd("LspAttach", {
              group = vim.api.nvim_create_augroup("my.lsp", {}),
              callback = function(ev)
                local function map_if_free(mode, lhs, rhs, opts)
                  opts = opts or {}

                  if vim.fn.maparg(lhs, mode) == "" then
                    vim.keymap.set(mode, lhs, rhs, opts)
                  end
                end

                -- If I'm using a picker for these, I want to use these keymaps for that picker
                map_if_free("n", "<leader>gs", vim.lsp.buf.document_symbol, { buffer = ev.buf, desc = "Symbols" })
                map_if_free("n", "<leader>gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "References" })

                vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition" })
                vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "Hover" })
                vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = ev.buf, desc = "Rename" })
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "Code actions" })
                vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { buffer = ev.buf, desc = "Format" })
              end,
            })
          end)
        end
      )
    end)
  end,
})
