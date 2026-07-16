vim.pack.add({
    "https://github/nvim-tree/nvim-web-devicons",
    "https://github.com/akinsho/bufferline.nvim",
})

local mocha = require("catppuccin.palettes").get_palette("mocha")

require("bufferline").setup({
    highlights = require("catppuccin.special.bufferline").get_theme({
        styles = { "bold" },

        custom = {
            mocha = {
                buffer_selected = {
                    bg = mocha.base,
                    fg = mocha.text,
                    bold = true,
                },
            },
        },
    }),

    options = {
        custom_filter = function(buf)
            return vim.bo[buf].filetype ~= "oil"
        end,
        modified_icon = "*",
        separator_style = "slant",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon
        end,
        show_duplicate_prefix = true,
    },
})
