-- lua/configs/lspconfig.lua
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- Servidores simples sin configuración extra
local servers = { "cssls", "ts_ls", "tailwindcss", "bashls" }

for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  })
  vim.lsp.enable(lsp)
end

-- HTML LSP — autocompletado inteligente de tags y atributos
vim.lsp.config("html", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "html" },
})
vim.lsp.enable("html")

-- Emmet — solo expansión de abreviaciones
vim.lsp.config("emmet_ls", {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "html", "css", "javascriptreact", "typescriptreact", "sass", "scss", "less" },
})
vim.lsp.enable("emmet_ls")
