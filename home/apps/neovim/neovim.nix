{ config, pkgs, ... }:
{
  programs.neovim = {
    withRuby = false;
    withPython3 = false;
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      # LSP servers
      pyright
      typescript-language-server
      jdt-language-server           # Java
      lua-language-server
      nil                           # Nix
    ];

    plugins = with pkgs.vimPlugins; [
      # tema
      tokyonight-nvim

      # treesitter
      nvim-treesitter.withAllGrammars

      # LSP
      nvim-lspconfig

      # autocompletado
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip

      # copilot
      copilot-lua
      copilot-cmp

      # ui
      telescope-nvim
      nvim-tree-lua
      lualine-nvim
      nvim-web-devicons
    ];

    extraLuaConfig = ''
      -- tema
      require("tokyonight").setup({ style = "night", transparent = false })
      vim.cmd("colorscheme tokyonight")

      -- opciones básicas
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.termguicolors = true

      -- leader
      vim.g.mapleader = " "
      local map = vim.keymap.set

      -- copilot
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
      require("copilot_cmp").setup()

      -- autocompletado
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"]   = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"]    = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- LSP
      local lsp = require("lspconfig")
      local caps = require("cmp_nvim_lsp").default_capabilities()

      lsp.pyright.setup({ capabilities = caps })
      lsp.tsserver.setup({ capabilities = caps })
      lsp.jdtls.setup({ capabilities = caps })
      lsp.lua_ls.setup({ capabilities = caps })
      lsp.nil_ls.setup({ capabilities = caps })

      -- keymaps LSP
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          map("n", "gd",         vim.lsp.buf.definition,     opts)
          map("n", "K",          vim.lsp.buf.hover,          opts)
          map("n", "<leader>rn", vim.lsp.buf.rename,         opts)
          map("n", "<leader>ca", vim.lsp.buf.code_action,    opts)
          map("n", "<leader>d",  vim.diagnostic.open_float,  opts)
          map("n", "[d",         vim.diagnostic.goto_prev,   opts)
          map("n", "]d",         vim.diagnostic.goto_next,   opts)
        end,
      })

      -- navegación ventanas
      map("n", "<leader>h", "<C-w>h")
      map("n", "<leader>l", "<C-w>l")
      map("n", "<leader>j", "<C-w>j")
      map("n", "<leader>k", "<C-w>k")

      -- archivo
      map("n", "<leader>w", ":w<CR>")
      map("n", "<leader>q", ":q<CR>")

      -- telescope
      local ok, telescope = pcall(require, "telescope.builtin")
      if ok then
        map("n", "<leader>ff", telescope.find_files)
        map("n", "<leader>fg", telescope.live_grep)
        map("n", "<leader>fb", telescope.buffers)
      end

      -- árbol de archivos
      local ok2, _ = pcall(require, "nvim-tree")
      if ok2 then
        require("nvim-tree").setup()
        map("n", "<leader>e", ":NvimTreeToggle<CR>")
      end

      -- lualine
      local ok3, lualine = pcall(require, "lualine")
      if ok3 then
        lualine.setup({ options = { theme = "tokyonight" } })
      end
    '';
  };
}
