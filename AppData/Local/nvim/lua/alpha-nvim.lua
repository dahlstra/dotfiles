require("plugin-loader").load_and_setup_once("alpha-nvim", { "https://github.com/goolord/alpha-nvim" }, function()
  require("alpha").setup(require("screen").config)
end)
