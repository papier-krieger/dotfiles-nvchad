require "nvchad.autocmds"

-- Reconocer archivos bash sin extensión
vim.filetype.add({
  filename = {
    [".bash_functions"] = "bash",
    [".bash_aliases"] = "bash",
    [".bash_profile"] = "bash",
    [".bashrc"] = "bash",
  },
})

-- Turn off CapsLock when entering normal mode
vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = "*:n*",
  callback = function()
    vim.fn.system("xset q | grep -q 'Caps Lock:.*on' && xdotool key Caps_Lock")
  end,
})


-- Auto-iniciar HTML LSP sin necesidad de .git o package.json
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "html" },
  callback = function()
    vim.lsp.start({
      name = "html",
      cmd = { "vscode-html-language-server", "--stdio" },
      root_dir = vim.fn.expand("%:p:h"),
      capabilities = require("nvchad.configs.lspconfig").capabilities,
    })
  end,
})

