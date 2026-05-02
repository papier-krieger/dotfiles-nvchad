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
