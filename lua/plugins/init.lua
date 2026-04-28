return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre',
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- SOPORTE WEB (HTML/CSS)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "bash",
        "html", "css", "javascript", "typescript", "tsx"
      },
    },
  },

  --  AUTO-TAG (Cierra etiquetas HTML solo)
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascriptreact", "typescriptreact" },
    opts = {},
  },


  {
    "nvchad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        names = false, -- No resalta palabras como "Blue", solo códigos hex/rgb
        RRGGBBAA = true, -- Soporte para transparencia
        rgb_fn = true, -- Soporte para funciones rgb() y rgba()
        hsl_fn = true, -- Soporte para funciones hsl() y hsla()
        css = true, -- Habilitar en archivos CSS
        sass = { enable = true, parsers = { "css" }, }, -- Soporte para Sass
      },
    },
  },



  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.completion = { autocomplete = false }
      local cmp = require "cmp"

      opts.mapping = {
        -- 1. TAB: Intenta expandir directamente sin mostrar menú
        ["<Tab>"] = cmp.mapping(function(fallback)
          -- Forzamos la apertura y confirmación inmediata del primer resultado
          cmp.complete({
            reason = cmp.ContextReason.Manual,
          })
          
          -- Pequeño retraso para que Emmet responda y confirmamos la primera opción
          vim.defer_fn(function()
            if cmp.visible() then
              cmp.confirm({ select = true })
            end
          end, 10) 
        end, { "i", "s" }),

        -- 2. CTRL + ESPACIO: Abre la lista para que puedas elegir
        ["<C-Space>"] = cmp.mapping.complete(),

        -- 3. NAVEGACIÓN (Solo cuando el menú de Ctrl+Space está abierto)
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        -- Enter para confirmar si estás eligiendo de la lista manual
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }
    end,
  },


}
