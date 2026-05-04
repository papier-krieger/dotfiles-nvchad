-- lua/configs/lspconfig.lua
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities
-- Lista de servidores a configurar
local servers = { "html", "cssls", "ts_ls", "tailwindcss", "emmet_ls", "bashls" }
-- Nueva forma de configurar servidores (sin usar require('lspconfig'))
for _, lsp in ipairs(servers) do
  vim.lsp.config(lsp, {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    -- Configuración extra solo para Emmet
    filetypes = lsp == "emmet_ls" and { 
      "html", "css", "javascriptreact", "typescriptreact", "sass", "scss", "less" 
    } or nil,
  })
  vim.lsp.enable(lsp)
end
