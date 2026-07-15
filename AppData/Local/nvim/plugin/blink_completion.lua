vim.pack.add({
    {
        src = "https://github.com/saghen/blink.cmp",
        name = "blink.cmp",
        version = vim.version.range("1.*"),
    },
})

require("blink.cmp").setup({
    keymap = {
        preset = "none",

        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },

        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },

        ["<Tab>"] = { "snippet_forward", "accept", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<CR>"] = { "snippet_forward", "accept", "fallback" },
    },

    signature = {
        enabled = true,
    },

    completion = {
        list = {
            selection = {
                preselect = true,
                auto_insert = false,
            },
        },
        trigger = {
            show_in_snippet = false,
        },
        menu = {
            border = "rounded",
            winblend = vim.o.pumblend,
            draw = {
                columns = {
                    { "kind_icon" },
                    { "label",             gap = 4 },
                    { "label_description", gap = 10 },
                    { "source_name" },
                },
            },
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
        },
    },

    sources = {
        default = { "lsp" },
        per_filetype = {
            markdown = { "buffer", "path", "snippets" },
            gitcommit = { "buffer", "path", "snippets" },
            gitrebase = { "buffer" },
            txt = { "buffer", "path", "snippets" },
            plaintext = { "buffer", "path", "snippets" },
        },
    },
})
