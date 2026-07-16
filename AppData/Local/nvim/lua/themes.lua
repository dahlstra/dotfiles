vim.pack.add({
    {
        src = "https://github.com/EdenEast/nightfox.nvim",
        name = "nightfox",
    },
    {
        src = "https://github.com/catppuccin/nvim",
        name = "catppuccin-nvim",
    },
    {
        src = "https://github.com/rebelot/kanagawa.nvim",
        name = "kanegawa",
    },
    {
        src = "https://github.com/vague-theme/vague.nvim",
        name = "vague",
    },
    {
        src = "https://github.com/abhilash26/mapledark.nvim",
        name = "mapledark",
    }
    -- {
    --     src = "",
    --     name = "",
    -- },
})

vim.cmd("colorscheme catppuccin")

vim.o.background = "dark"
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
