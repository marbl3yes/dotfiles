if true then
  return {}
end

return {
  {
    "folke/which-key.nvim",
    opts = {},
    keys = {
      { "<leader>m", "+markdown", desc = "Markdown" },
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
