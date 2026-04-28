local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    html = { "prettier" },
    css = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
  },

  format_on_save = {
    -- Estos ajustes aseguran que formatee al guardar automáticamente
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

return options
