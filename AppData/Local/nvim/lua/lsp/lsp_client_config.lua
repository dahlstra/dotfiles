vim.pack.add({
    { src = "https://github.com/neovim/nvim-lspconfig" }
})

local lua_config = {
    settings = {
        Lua = {
            runtime = {
                version = "LuaJIT",
            },
            workspace = {
                library = {
                    vim.env.VIMRUNTIME,
                },
            },
            completion = {
                callSnippet = "Disable",
                keywordSnippet = "Disable",
            },
        },
    },
}

vim.lsp.config("powershell_es", {
    -- For some reason it couldn't find this on its own so I had to specify it
    bundle_path = vim.fn.stdpath "data" .. "/mason/packages/powershell-editor-services",
})

vim.lsp.config("lua_ls", lua_config)
vim.lsp.enable({ "lua_ls", "marksman", "powershell_es", "clangd" })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    callback = function(ev)
        local function safe_map(mode, lhs, rhs, opts)
            local function has_keymap(bufnr)
                bufnr = bufnr or 0

                -- Expand leaders
                lhs = lhs:gsub('<leader>', vim.g.mapleader or '\\')
                lhs = lhs:gsub('<localleader>', vim.g.maplocalleader or '\\')

                local keymaps = vim.api.nvim_buf_get_keymap(bufnr, mode)
                for _, map in ipairs(keymaps) do
                    if map.lhs == lhs then
                        return true
                    end
                end

                -- also check global keymaps if buffer-local didn't have it
                for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
                    if map.lhs == lhs then
                        return true
                    end
                end
                return false
            end

            opts = opts or {}
            opts.buffer = opts.buffer or 0
            if not has_keymap(opts.buffer) then
                vim.keymap.set(mode, lhs, rhs, opts)
            end
        end

        safe_map("n", "<leader>gs", vim.lsp.buf.document_symbol, { buffer = ev.buf, desc = "Symbols" })
        safe_map("n", "<leader>gr", vim.lsp.buf.references, { buffer = ev.buf, desc = "References" })

        vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, { desc = "Definition" })
        vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
        vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Actions" })
        vim.keymap.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format" })
    end,
})
