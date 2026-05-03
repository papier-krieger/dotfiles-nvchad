-- lua/configs/lspconfig.lua
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local servers = { "html", "cssls", "ts_ls", "tailwindcss", "emmet_ls", "bashls" }

for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    root_dir = function(fname)
      local f = type(fname) == "number" and vim.api.nvim_buf_get_name(fname) or fname
      return vim.fs.root(f, { ".git", "package.json", ".editorconfig" })
      or vim.fs.dirname(f)
    end,
    filetypes = lsp == "emmet_ls" and {
      "html", "css", "javascriptreact", "typescriptreact", "sass", "scss", "less"
    } or nil,
  })
  vim.lsp.enable(lsp)
end
