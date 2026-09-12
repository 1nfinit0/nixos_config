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
      vim.opt.scrolloff = 0
      vim.opt.sidescrolloff = 0

      -- leader
      vim.g.mapleader = " "
      local map = vim.keymap.set

      local function visual_move(motion)
        return function()
          vim.cmd("normal! v")
          vim.cmd("normal! " .. motion)
        end
      end

      local function page_up_or_top()
        if vim.fn.line(".") <= vim.fn.winheight(0) then
          return vim.api.nvim_replace_termcodes("gg", true, false, true)
        else
          return vim.api.nvim_replace_termcodes("<C-b>", true, false, true)
        end
      end

      local function page_down_or_bottom()
        if vim.fn.line("$") - vim.fn.line(".") <= vim.fn.winheight(0) then
          return vim.api.nvim_replace_termcodes("G", true, false, true)
        else
          return vim.api.nvim_replace_termcodes("<C-f>", true, false, true)
        end
      end

      local function scroll_line_up()
        vim.cmd("normal! <C-y>")
      end

      local function scroll_line_down()
        vim.cmd("normal! <C-e>")
      end

      local autosave_timers = {}

      local function save_buffer(bufnr)
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end

        if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable or not vim.bo[bufnr].modified then
          return
        end

        pcall(vim.api.nvim_buf_call, bufnr, function()
          vim.cmd("silent! update")
        end)
      end

      local function schedule_autosave(bufnr)
        if vim.bo[bufnr].buftype ~= "" or not vim.bo[bufnr].modifiable then
          return
        end

        local timer = autosave_timers[bufnr]
        if timer ~= nil then
          timer:stop()
          timer:close()
        end

        timer = vim.loop.new_timer()
        autosave_timers[bufnr] = timer

        timer:start(700, 0, vim.schedule_wrap(function()
          if autosave_timers[bufnr] ~= timer then
            return
          end

          autosave_timers[bufnr] = nil
          save_buffer(bufnr)
          timer:stop()
          timer:close()
        end))
      end

      local terminal_state = {
        win = nil,
        buf = nil,
        cwd = nil,
        origin_win = nil,
      }

      local function current_file_dir()
        local file_dir = vim.fn.expand("%:p:h")
        if file_dir == "" then
          return vim.fn.getcwd()
        end
        return file_dir
      end

      local function has_real_file()
        return vim.fn.expand("%:p") ~= ""
      end

      local function open_terminal(cwd)
        terminal_state.origin_win = vim.api.nvim_get_current_win()
        vim.cmd("botright 12new")
        terminal_state.win = vim.api.nvim_get_current_win()
        terminal_state.cwd = cwd
        vim.wo[terminal_state.win].winfixheight = true
        vim.wo[terminal_state.win].number = false
        vim.wo[terminal_state.win].relativenumber = false
        vim.wo[terminal_state.win].signcolumn = "no"
        vim.api.nvim_win_set_height(terminal_state.win, 12)

        vim.fn.termopen(vim.o.shell, { cwd = cwd })
        terminal_state.buf = vim.api.nvim_get_current_buf()
        vim.bo[terminal_state.buf].bufhidden = "hide"

        vim.cmd("startinsert")
      end

      local function close_terminal()
        if terminal_state.win ~= nil and vim.api.nvim_win_is_valid(terminal_state.win) then
          vim.api.nvim_win_close(terminal_state.win, false)
        end

        if terminal_state.origin_win ~= nil and vim.api.nvim_win_is_valid(terminal_state.origin_win) then
          vim.api.nvim_set_current_win(terminal_state.origin_win)
        end

        terminal_state.win = nil
        terminal_state.buf = nil
        terminal_state.cwd = nil
        terminal_state.origin_win = nil
      end

      local function toggle_terminal()
        if not has_real_file() then
          vim.notify("Abre primero un archivo para usar la terminal integrada.", vim.log.levels.INFO)
          return
        end

        if terminal_state.win ~= nil and vim.api.nvim_win_is_valid(terminal_state.win) then
          close_terminal()
          return
        end

        open_terminal(current_file_dir())
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

      -- desplazamiento de pantalla
      map("n", "<C-Up>", scroll_line_up, { silent = true })
      map("n", "<C-Down>", scroll_line_down, { silent = true })
      map("n", "<C-k>", scroll_line_up, { silent = true })
      map("n", "<C-j>", scroll_line_down, { silent = true })
      map("v", "<C-Up>", scroll_line_up, { silent = true })
      map("v", "<C-Down>", scroll_line_down, { silent = true })
      map("v", "<C-k>", scroll_line_up, { silent = true })
      map("v", "<C-j>", scroll_line_down, { silent = true })
      map("i", "<C-Up>", function()
        return vim.api.nvim_replace_termcodes("<C-o><C-y>", true, false, true)
      end, { expr = true })
      map("i", "<C-Down>", function()
        return vim.api.nvim_replace_termcodes("<C-o><C-e>", true, false, true)
      end, { expr = true })
      map("i", "<C-k>", function()
        return vim.api.nvim_replace_termcodes("<C-o><C-y>", true, false, true)
      end, { expr = true })
      map("i", "<C-j>", function()
        return vim.api.nvim_replace_termcodes("<C-o><C-e>", true, false, true)
      end, { expr = true })

      -- salto de página
      map("n", "<PageUp>", page_up_or_top, { expr = true })
      map("n", "<PageDown>", page_down_or_bottom, { expr = true })
      map("v", "<PageUp>", "<C-b>")
      map("v", "<PageDown>", "<C-f>")
      map("i", "<PageUp>", function()
        if vim.fn.line(".") <= vim.fn.winheight(0) then
          return vim.api.nvim_replace_termcodes("<C-o>gg", true, false, true)
        else
          return vim.api.nvim_replace_termcodes("<C-o><C-b>", true, false, true)
        end
      end, { expr = true })
      map("i", "<PageDown>", function()
        if vim.fn.line("$") - vim.fn.line(".") <= vim.fn.winheight(0) then
          return vim.api.nvim_replace_termcodes("<C-o>G", true, false, true)
        else
          return vim.api.nvim_replace_termcodes("<C-o><C-f>", true, false, true)
        end
      end, { expr = true })

        -- terminal integrada
        vim.api.nvim_create_user_command("TermToggle", toggle_terminal, {})

        map({ "n", "v", "i", "t" }, "<C-<>", toggle_terminal, { silent = true })

        -- autoguardado
        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "InsertLeave", "FocusLost", "BufLeave" }, {
          callback = function(ev)
            schedule_autosave(ev.buf)
          end,
        })

        vim.api.nvim_create_autocmd("BufUnload", {
          callback = function(ev)
            local timer = autosave_timers[ev.buf]
            if timer ~= nil then
              timer:stop()
              timer:close()
              autosave_timers[ev.buf] = nil
            end
          end,
        })

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

        require("nvim-tree").setup({
          view = {
            side = "right",
            width = 35,
          },
        })
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
