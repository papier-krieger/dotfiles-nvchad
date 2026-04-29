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

  -- Soporte para lenguajes web (HTML/CSS/JS)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc", "bash",
        "html", "css", "javascript", "typescript", "tsx"
      },
    },
  },

  -- Cierre automático de etiquetas HTML
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascriptreact", "typescriptreact" },
    opts = {},
  },

  -- Resaltado de colores (hex, rgb, hsl) en el editor
  {
    "nvchad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        names = false,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        sass = { enable = true, parsers = { "css" } },
      },
    },
  },

  -- Configuración del motor de autocompletado (nvim-cmp)
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.completion = { autocomplete = false }
      local cmp = require "cmp"

      opts.mapping = {
        -- 1. TAB: Inserta tabulación si hay espacio, o intenta expandir si hay texto
        ["<Tab>"] = cmp.mapping(function(fallback)
          local col = vim.fn.col('.') - 1
          if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
            fallback()
          else
            cmp.complete({ reason = cmp.ContextReason.Manual })
            
            vim.defer_fn(function()
              if cmp.visible() then
                cmp.confirm({ select = true })
              else
                fallback()
              end
            end, 10) 
          end
        end, { "i", "s" }),

        -- 2. CTRL + ESPACIO: Abre manualmente el menú de sugerencias
        ["<C-Space>"] = cmp.mapping.complete(),

        -- 3. NAVEGACIÓN: Atajos para moverse dentro del menú abierto
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
      }
    end,
  },
}
