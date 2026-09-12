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

      # ui
      telescope-nvim
      nvim-tree-lua
      lualine-nvim
      nvim-web-devicons
    ];

    initLua = ''
      -- tema
      require("tokyonight").setup({ style = "night", transparent = false })
      vim.cmd("colorscheme tokyonight")

      -- opciones básicas
      vim.opt.number = true
      vim.opt.relativenumber = false
      vim.opt.numberwidth = 2
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.expandtab = true
      vim.opt.termguicolors = true
      vim.opt.cursorline = false
      vim.opt.guicursor = "n-v-c:ver25,i-ci-ve:ver25,r-cr:hor20,o:hor50"
      vim.opt.clipboard = "unnamedplus"

      -- leader
      vim.g.mapleader = " "
      local map = vim.keymap.set

      local function visual_move(motion)
        return function()
          vim.cmd("normal! v")
          vim.cmd("normal! " .. motion)
        end
      end

      map("n", "<S-left>",  visual_move("h"))
      map("n", "<S-right>", visual_move("l"))
      map("n", "<S-up>",    visual_move("k"))
      map("n", "<S-down>",  visual_move("j"))

      map("v", "<S-left>",  "h")
      map("v", "<S-right>", "l")
      map("v", "<S-up>",    "k")
      map("v", "<S-down>",  "j")

      map("v", "<Left>",  '<Esc>h')
      map("v", "<Right>", '<Esc>l')
      map("v", "<Up>",    '<Esc>k')
      map("v", "<Down>",  '<Esc>j')

      map("v", "d", '"+d')
      map("v", "x", '"+d')
      map("v", "y", '"+y')
      map("v", "<C-c>", '"+y')
      map("n", "<C-v>", '"+p')
      map("i", "<C-v>", '<Esc>"+pi')

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
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- LSP
local caps =
  require("cmp_nvim_lsp")
    .default_capabilities()

vim.lsp.config("pyright", {
  capabilities = caps,
})

vim.lsp.config("ts_ls", {
  capabilities = caps,
})

vim.lsp.config("jdtls", {
  capabilities = caps,
})

vim.lsp.config("lua_ls", {
  capabilities = caps,
})

vim.lsp.config("nil_ls", {
  capabilities = caps,
})

vim.lsp.enable("pyright")
vim.lsp.enable("ts_ls")
vim.lsp.enable("jdtls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("nil_ls")

-- keymaps LSP
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local opts = { buffer = ev.buf }

    map("n", "gd",
      vim.lsp.buf.definition, opts)

    map("n", "K",
      vim.lsp.buf.hover, opts)

    map("n", "<leader>rn",
      vim.lsp.buf.rename, opts)

    map("n", "<leader>ca",
      vim.lsp.buf.code_action, opts)

    map("n", "<leader>d",
      vim.diagnostic.open_float, opts)

    map("n", "[d",
      vim.diagnostic.goto_prev, opts)

    map("n", "]d",
      vim.diagnostic.goto_next, opts)
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
        local api = require("nvim-tree.api")

        local function toggle_tree_with_focus()
          if api.tree.is_visible() then
            api.tree.close()
            vim.cmd("wincmd p")
          else
            api.tree.open()
            api.tree.focus()
          end
        end

        require("nvim-tree").setup()
        map({ "n", "i" }, "<C-b>", toggle_tree_with_focus)
      end

      -- lualine
      local ok3, lualine = pcall(require, "lualine")
      if ok3 then
        lualine.setup({ options = { theme = "tokyonight" } })
      end
    '';
  };
}
