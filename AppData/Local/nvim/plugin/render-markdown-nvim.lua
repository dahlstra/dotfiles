vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      require("plugin-loader").load_and_setup_once("render-markdown", {
        "https://github.com/MeanderingProgrammer/render-markdown.nvim",
        "https://github.com/nvim-mini/mini.nvim",
        "https://github.com/nvim-tree/nvim-web-devicons",
      }, function()
        local utils = require("utils.highlights")
        utils.clear_hl_background("RenderMarkdownH1Bg")
        utils.clear_hl_background("RenderMarkdownH2Bg")
        utils.clear_hl_background("RenderMarkdownH3Bg")
        utils.clear_hl_background("RenderMarkdownH4Bg")
        utils.clear_hl_background("RenderMarkdownH5Bg")
        utils.clear_hl_background("RenderMarkdownH6Bg")
        utils.clear_hl_background("RenderMarkdownCodeInline")

        require("render-markdown").setup({
          enabled = true,
          completions = { blink = { enabled = true } },
          heading = {
            backgrounds = {
              "RenderMarkdownH1Bg",
              "RenderMarkdownH2Bg",
              "RenderMarkdownH3Bg",
              "RenderMarkdownH4Bg",
              "RenderMarkdownH5Bg",
              "RenderMarkdownH6Bg",
            },
          },

          -- Disables the background (better for transparent background) and language icons
          code = { disable_background = true, language = false },
        })
      end)
    end)
  end,
})
