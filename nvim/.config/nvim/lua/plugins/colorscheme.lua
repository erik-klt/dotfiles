return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard", -- "hard", "soft" oder "dark" für den perfekten Vibe
        transparent_mode = true, -- Macht den Hintergrund durchsichtig, passend zu Kitty!
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gruvbox",
    },
  },
}

