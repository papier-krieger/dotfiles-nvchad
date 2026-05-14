return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre',
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require "configs.lspconfig"
    end,
  },

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


  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      local types = require "cmp.types"
      local kind = types.lsp.CompletionItemKind

      -- VARIABLE INTERNA PARA FILTRADO DINÁMICO REAL
      -- nil = Todo | "nvim_lsp" | "luasnip" | "path" | "buffer" | "LSP_Calls" | "LSP_Variables"
      local current_filter = nil

      -- 1. FUENTES GLOBALES DINÁMICAS CON SUBFILTROS MICRO INTEGRADOS
      opts.sources = cmp.config.sources({
        {
          name = "nvim_lsp",
          entry_filter = function(entry, ctx)
            if current_filter == nil or current_filter == "nvim_lsp" then 
              return true 
            end

            -- SUBFILTRO: Solo Funciones, Métodos y Constructores (Acciones)
            if current_filter == "LSP_Calls" then
              local k = entry:get_kind()
              return k == kind.Method or k == kind.Function or k == kind.Constructor
            end

            -- SUBFILTRO: Solo Variables, Constantes, Campos y Propiedades (Datos)
            if current_filter == "LSP_Variables" then
              local k = entry:get_kind()
              return k == kind.Variable or k == kind.Constant or k == kind.Field or k == kind.Property
            end

            return false
          end
        },
        {
          name = "luasnip",
          entry_filter = function() return current_filter == nil or current_filter == "luasnip" end
        },
        {
          name = "path",
          entry_filter = function() return current_filter == nil or current_filter == "path" end
        },
        {
          name = "buffer",
          entry_filter = function() return current_filter == nil or current_filter == "buffer" end
        },
      })

      -- RESTAURAR EL FILTRO GLOBAL AL CERRAR EL POPUP
      cmp.event:on("menu_closed", function()
        current_filter = nil
      end)

      opts.preselect = cmp.PreselectMode.None
      opts.completion = {
        autocomplete = false,
        completeopt = "menu,menuone,noselect",
      }

      -- 2. NAVEGACIÓN COMPARTIDA Y CONTROL DEL POPUP (Teclas simples)
      opts.mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
          else
            local col = vim.fn.col('.') - 1
            local line = vim.fn.getline('.')
            if col == 0 or line:sub(col, col):match('%s') then
              fallback()
            else
              cmp.complete()
              vim.defer_fn(function()
                if cmp.visible() then cmp.confirm({ select = true }) else fallback() end
              end, 20)
            end
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select }) else fallback() end
        end, { "i", "s" }),

        ["<A-j>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_next_item({ behavior = cmp.SelectBehavior.Select }) else fallback() end
        end, { "i", "s" }),

        ["<A-k>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select }) else fallback() end
        end, { "i", "s" }),

        ["<CR>"] = cmp.mapping(function(fallback)
          if cmp.visible() and cmp.get_selected_entry() then cmp.confirm({ select = false }) else fallback() end
        end, { "i", "s" }),

        ["<Esc>"] = cmp.mapping(function(fallback)
          if cmp.visible() then cmp.close() end
          fallback()
        end, { "i", "s" }),

        ["<C-Space>"] = cmp.mapping(function()
          if cmp.visible() then cmp.close() end
          current_filter = nil
          cmp.complete()
          vim.defer_fn(function() if cmp.visible() then cmp.select_next_item({ behavior = cmp.SelectBehavior.Select }) end end, 20)
        end, { "i", "s" }),
      }

      -- ====================================================================
      -- CAPA ALT CAPTURADA POR NEOVIM (Ergonomía pura de un solo paso)
      -- ====================================================================
      local function create_alt_filter(filter_target)
        return function()
          if cmp.visible() then cmp.close() end
          current_filter = filter_target
          cmp.complete()

          local delay = filter_target == "luasnip" and 35 or 20
          vim.defer_fn(function()
            if cmp.visible() then 
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select }) 
            end
          end, delay)
        end
      end

      -- Mapeos nativos en Modo Inserto para la mano izquierda
      vim.keymap.set("i", "<A-a>", function() -- All (Resetear filtros)
        if cmp.visible() then cmp.close() end
        current_filter = nil
        cmp.complete()
      end, { desc = "CMP: Mostrar todas las fuentes" })

      vim.keymap.set("i", "<A-g>", create_alt_filter("nvim_lsp"),      { desc = "CMP: Solo Genius (LSP Completo)" })
      vim.keymap.set("i", "<A-s>", create_alt_filter("luasnip"),       { desc = "CMP: Solo Snippets" })
      vim.keymap.set("i", "<A-f>", create_alt_filter("path"),          { desc = "CMP: Solo Files (Rutas)" })
      vim.keymap.set("i", "<A-w>", create_alt_filter("buffer"),        { desc = "CMP: Solo Words (Buffer)" })

      -- Los dos subfiltros micro estratégicos para tu Home-Row
      vim.keymap.set("i", "<A-c>", create_alt_filter("LSP_Calls"),     { desc = "CMP: LSP -> Solo Funciones/Métodos" })
      vim.keymap.set("i", "<A-v>", create_alt_filter("LSP_Variables"), { desc = "CMP: LSP -> Solo Variables/Campos" })

      -- 3. INTERFAZ VISUAL COHERENTE CON TUS PROPIAS MNEMÓNICAS EN EL FORMATTING
      opts.formatting = {
        format = function(entry, vim_item)
          -- Ajuste dinámico de la etiqueta según el subfiltro activo de la LSP
          local lsp_label = "[Genius]"
          if current_filter == "LSP_Calls" then
            lsp_label = "[Calls]"
          elseif current_filter == "LSP_Variables" then
            lsp_label = "[Variables]"
          end

          vim_item.menu = ({
            nvim_lsp = lsp_label,
            luasnip  = "[Snippets]", -- Sincronizado semánticamente con <A-s>
            path     = "[Files]",    -- Sincronizado semánticamente con <A-f>
            buffer   = "[Words]",    -- Sincronizado semánticamente con <A-w>
          })[entry.source.name]
          return vim_item
        end,
      }

      return opts
    end,

    config = function(_, opts)
      local cmp = require "cmp"
      cmp.setup(opts)
      cmp.setup.cmdline("/", { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*", -- Usa la última versión estable
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte", "vue" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = {
        enable = true,
        update_root = true,
      },

      hijack_cursor = true,
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
    },
  },

  {
    "tpope/vim-unimpaired",
    event = "VeryLazy",
  },


  {
    "karb94/neoscroll.nvim",
    keys = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb" },

    config = function()
      local neoscroll = require('neoscroll')
      neoscroll.setup({
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = true,
        easing_function = "quadratic",
      })

      -- Esta es la nueva forma oficial en lugar de set_mappings
      local keymap = {
        ["<C-u>"] = function() neoscroll.ctrl_u({ duration = 250 }) end,
        ["<C-d>"] = function() neoscroll.ctrl_d({ duration = 250 }) end,
        ["<C-b>"] = function() neoscroll.ctrl_b({ duration = 450 }) end,
        ["<C-f>"] = function() neoscroll.ctrl_f({ duration = 450 }) end,
        ["zt"]    = function() neoscroll.zt({ half_win_duration = 250 }) end,
        ["zz"]    = function() neoscroll.zz({ half_win_duration = 250 }) end,
        ["zb"]    = function() neoscroll.zb({ half_win_duration = 250 }) end,
      }

      local modes = { 'n', 'v', 'x' }
      for key, func in pairs(keymap) do
        vim.keymap.set(modes, key, func)
      end
    end,
  },

  {
    "mbbill/undotree",
    lazy = false, 
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
    end,
  },

  {
    "andymass/vim-matchup",
    lazy = false, -- Importante para que % funcione desde el inicio
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    config = function()
      local select = require("nvim-treesitter-textobjects.select")
      local keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["ab"] = "@block.outer",
        ["ib"] = "@block.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      }
      for key, query in pairs(keymaps) do
        vim.keymap.set({ "x", "o" }, key, function()
          select.select_textobject(query, "textobjects")
        end)
      end
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      return opts
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      opts.defaults = opts.defaults or {}
      opts.defaults.mappings = {
        i = {
          ["<C-j>"] = require("telescope.actions").move_selection_next,
          ["<C-k>"] = require("telescope.actions").move_selection_previous,
        }
      }
    end,
  },

  {
    "L3MON4D3/LuaSnip",
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvchad/lua/snippets" })
    end,
  },


  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePost" },
    config = function()
      local lint = require("lint")

      -- Conectamos los archivos HTML con el htmlhint que instalaste en Mason
      lint.linters_by_ft = {
        html = { "htmlhint" },
      }

      -- Automatización: Analiza el archivo al abrir, guardar o salir del modo inserto
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

}
