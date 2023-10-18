return {
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>m"] = { name = "+markdown" },
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    keys = {
      { "<Leader>mp", "<Plug>MarkdownPreview", desc = "Markdown Preview" },
    },
  },
}
