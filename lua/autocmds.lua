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
