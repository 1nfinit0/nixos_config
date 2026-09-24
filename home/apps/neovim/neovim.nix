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
      jdt-language-server            # Java
      lua-language-server
      nil                            # Nix
    ];

    plugins = with pkgs.vimPlugins; [
      copilot-vim

      # tema
      tokyonight-nvim

      # treesitter
      nvim-treesitter.withAllGrammars

      # LSP
      nvim-lspconfig
      nvim-jdtls                     # setup dedicado para Java (workspace propio por proyecto)

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
      vim.opt.signcolumn = "yes"
      vim.opt.guicursor = "n-v-c:ver25,i-ci-ve:ver25,r-cr:hor20,o:hor50"
      vim.opt.clipboard = "unnamedplus"
      vim.opt.scrolloff = 0
      vim.opt.sidescrolloff = 0

      vim.diagnostic.config({
        virtual_text = {
          spacing = 2,
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = true,
        severity_sort = true,
        float = {
          border = "rounded",
          source = "if_many",
        },
      })

      local diagnostic_signs = {
        Error = "",
        Warn = "",
        Hint = "󰌵",
        Info = "",
      }

      for type, icon in pairs(diagnostic_signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- leader
      vim.g.mapleader = " "
      local map = vim.keymap.set

      local function is_editable_buffer(bufnr)
        bufnr = bufnr or 0
        return vim.bo[bufnr].buftype == "" and vim.bo[bufnr].modifiable
      end

      -- ==========================================================
      -- Comportamiento "tipo VSCode"
      -- ==========================================================
      -- 1) Siempre se abre en modo insert (autocmd más abajo).
      -- 2) Shift+flecha entra a Visual y extiende la selección.
      -- 3) La terminal no puede detectar "soltar Shift" (no hay
      --    evento de key-up para modificadores), así que se usa la
      --    flecha SIN shift como señal de "ya solté shift": si estás
      --    en Visual y presionas una flecha normal, se cancela la
      --    selección y vuelves a insert en la nueva posición.
      -- 4) Si por algún motivo terminas en Normal (Esc manual, :w,
      --    una acción de LSP, etc.), una flecha normal también te
      --    mueve y te regresa a insert, para que Normal nunca quede
      --    "pegado" sin que lo pidas explícitamente con un comando.

      local function visual_move(motion)
        return function()
          vim.cmd("normal! v")
          vim.cmd("normal! " .. motion)
        end
      end

      local function move_and_insert(motion)
        return function()
          vim.cmd("normal! " .. motion)
          -- solo "editar" si el buffer actual es realmente editable
          -- (en nvim-tree, quickfix, etc. la flecha debe quedarse como
          -- simple movimiento, sin forzar insert)
          if is_editable_buffer(0) then
            vim.cmd("startinsert")
          end
        end
      end

      -- Normal -> Visual (inicia selección)
      map("n", "<S-Left>",  visual_move("h"))
      map("n", "<S-Right>", visual_move("l"))
      map("n", "<S-Up>",    visual_move("k"))
      map("n", "<S-Down>",  visual_move("j"))

      -- Insert -> Visual (inicia selección mientras escribes).
      -- Importante: SIN expr = true. El rhs ya es la secuencia de teclas
      -- literal a enviar ("<Esc>" + "v" + motion). Si se marca
      -- expr = true, Neovim intenta *evaluar* ese texto como una
      -- expresión de Vimscript en vez de enviarlo como teclas, y truena
      -- con "E15: Invalid expression: ..." -- ese era el bug.
      map("i", "<S-Left>",  "<Esc>vh")
      map("i", "<S-Right>", "<Esc>vl")
      map("i", "<S-Up>",    "<Esc>vk")
      map("i", "<S-Down>",  "<Esc>vj")

      -- Visual: seguir extendiendo mientras "sigues con shift"
      map("v", "<S-Left>",  "h")
      map("v", "<S-Right>", "l")
      map("v", "<S-Up>",    "k")
      map("v", "<S-Down>",  "j")

      -- Visual -> Insert ("soltaste shift": cancela selección y sigue
      -- editando). Mismo motivo que arriba: nada de expr = true aquí.
      map("v", "<Left>",  "<Esc>i")
      map("v", "<Right>", "<Esc>i")
      map("v", "<Up>",    "<Esc>i")
      map("v", "<Down>",  "<Esc>i")

      -- Normal -> Insert (si quedaste en Normal, una flecha te regresa a editar)
      map("n", "<Left>",  move_and_insert("h"))
      map("n", "<Right>", move_and_insert("l"))
      map("n", "<Up>",    move_and_insert("k"))
      map("n", "<Down>",  move_and_insert("j"))

      -- desplazamiento de pantalla
      local function scroll_line_up()
        vim.cmd("normal! <C-y>")
      end

      local function scroll_line_down()
        vim.cmd("normal! <C-e>")
      end

      map("n", "<C-Up>",   scroll_line_up,   { silent = true })
      map("n", "<C-Down>", scroll_line_down, { silent = true })
      map("n", "<C-k>",    scroll_line_up,   { silent = true })
      map("n", "<C-j>",    scroll_line_down, { silent = true })
      map("v", "<C-Up>",   scroll_line_up,   { silent = true })
      map("v", "<C-Down>", scroll_line_down, { silent = true })
      map("v", "<C-k>",    scroll_line_up,   { silent = true })
      map("v", "<C-j>",    scroll_line_down, { silent = true })
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

      map("n", "<PageUp>",   page_up_or_top,      { expr = true })
      map("n", "<PageDown>", page_down_or_bottom, { expr = true })
      map("v", "<PageUp>",   "<C-b>")
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

      -- ==========================================================
      -- Autoguardado + autoinsert al abrir buffers
      -- ==========================================================
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

      local function start_insert_on_file_buffer(ev)
        if vim.bo[ev.buf].buftype ~= "" then
          return
        end

        if not vim.bo[ev.buf].modifiable then
          return
        end

        -- "nvim ." abre un buffer para el directorio antes de que
        -- nvim-tree lo reemplace por su árbol; sin este chequeo, ese
        -- buffer de directorio dispara insert por un instante.
        local name = vim.api.nvim_buf_get_name(ev.buf)
        if name == "" or vim.fn.isdirectory(name) == 1 then
          return
        end

        vim.schedule(function()
          if not (vim.api.nvim_buf_is_valid(ev.buf) and vim.api.nvim_get_current_buf() == ev.buf) then
            return
          end

          -- por si para cuando corre esto ya quedó como el árbol de nvim-tree
          if vim.bo[ev.buf].filetype == "NvimTree" then
            return
          end

          vim.cmd("startinsert")
        end)
      end

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

      vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        callback = start_insert_on_file_buffer,
      })

      -- ==========================================================
      -- Terminal integrada
      -- ==========================================================
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

      vim.api.nvim_create_user_command("TermToggle", toggle_terminal, {})

      -- Ctrl+< para alternar la terminal. OJO: "<C-<>" no es válido -- un
      -- "<" literal dentro de una notación de tecla especial debe
      -- escribirse como "lt" (ver :help <>), si no, Neovim no parsea
      -- bien el mapeo.
      map({ "n", "v", "i", "t" }, "<C-lt>", toggle_terminal, { silent = true })

      -- portapapeles del sistema
      map("v", "d", '"+d')
      map("v", "x", '"+d')
      map("v", "y", '"+y')
      map("v", "<C-c>", '"+y')
      map("n", "<C-v>", '"+p')
      map("i", "<C-v>", '<Esc>"+pi')

      -- ==========================================================
      -- Autocompletado
      -- ==========================================================
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"]     = cmp.mapping.select_next_item(),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- ==========================================================
      -- LSP
      -- ==========================================================
      local caps = require("cmp_nvim_lsp").default_capabilities()

      vim.lsp.config("pyright", { capabilities = caps })
      vim.lsp.config("ts_ls", { capabilities = caps })
      vim.lsp.config("lua_ls", { capabilities = caps })
      vim.lsp.config("nil_ls", { capabilities = caps })

      vim.lsp.enable("pyright")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("nil_ls")

      -- Java (jdtls) va aparte con nvim-jdtls: a diferencia de los
      -- servidores de arriba, jdtls necesita su propio "workspace" de
      -- datos (-data) por proyecto. Sin eso, reutiliza o corrompe el
      -- workspace de la última sesión y termina tratando cualquier
      -- archivo como "non-project file" aunque el proyecto sí tenga
      -- pom.xml/build.gradle -- esa es la causa típica del mensaje.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function()
          local ok_jdtls, jdtls = pcall(require, "jdtls")
          if not ok_jdtls then
            return
          end

          local ok_setup, jdtls_setup = pcall(require, "jdtls.setup")
          if not ok_setup then
            return
          end

          local root_markers = {
            "settings.gradle", "settings.gradle.kts",
            "pom.xml", "build.gradle", "build.gradle.kts",
            "mvnw", "gradlew",
            "build.xml", "nbproject",     -- proyectos Ant / NetBeans
            ".project", ".classpath",     -- metadata nativa de Eclipse
            ".git",
          }
          local root_dir = jdtls_setup.find_root(root_markers)
          if root_dir == "" then
            -- de verdad no hay proyecto (ni pom.xml, ni .git, nada):
            -- aquí sí es correcto que solo tengas resaltado de sintaxis.
            return
          end

          -- workspace único y estable por proyecto, derivado de la ruta
          -- absoluta de su raíz (evita choques entre proyectos con el
          -- mismo nombre de carpeta)
          local workspace_dir = vim.fn.stdpath("cache")
            .. "/jdtls-workspace/"
            .. root_dir:gsub("[/\\:]", "_")

          -- JDT LS solo "importa" automáticamente proyectos Maven,
          -- Gradle o con metadata de Eclipse (.project/.classpath) --
          -- NO sabe leer build.xml de Ant. Sin decirle nada más, root_dir
          -- se detecta bien pero el proyecto igual queda como carpeta
          -- de archivos sueltos ("non-project file"). Para Ant hay que
          -- declarar la carpeta de fuentes a mano vía sourcePaths (modo
          -- "unmanaged folder", soportado oficialmente por JDT LS).
          local has_build_tool = vim.fn.filereadable(root_dir .. "/pom.xml") == 1
            or vim.fn.filereadable(root_dir .. "/build.gradle") == 1
            or vim.fn.filereadable(root_dir .. "/build.gradle.kts") == 1
            or vim.fn.filereadable(root_dir .. "/.classpath") == 1

          local java_settings = {
            signatureHelp = { enabled = true },
            completion = { favoriteStaticMembers = {} },
          }

          if not has_build_tool then
            -- Ajusta esta lista a donde realmente estén tus .java
            -- (relativo a root_dir; layouts típicos de Ant/NetBeans
            -- usan "src", a veces "src/java" o varios módulos sueltos).
            java_settings.project = {
              sourcePaths = { "src" },
              -- si tienes jars externos en, por ejemplo, root/lib:
              -- referencedLibraries = vim.fn.glob(root_dir .. "/lib/*.jar", true, true),
            }
          end

          jdtls.start_or_attach({
            cmd = { "jdtls", "-data", workspace_dir },
            root_dir = root_dir,
            capabilities = caps,
            settings = { java = java_settings },
            -- respaldo: si JDT LS decide "es un proyecto sin nada" antes
            -- de recibir el settings normal, esto se lo manda también
            -- desde el arranque mismo.
            init_options = { settings = { java = java_settings } },
          })
        end,
      })

      -- keymaps de LSP (aplica a cualquier servidor, incluido jdtls)
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }

          map("n", "gd", vim.lsp.buf.definition, opts)
          map("n", "K", vim.lsp.buf.hover, opts)
          map("n", "<leader>rn", vim.lsp.buf.rename, opts)
          map("n", "<leader>ca", vim.lsp.buf.code_action, opts)

          map({ "n", "v" }, "<C-.>", vim.lsp.buf.code_action,
            vim.tbl_extend("force", opts, { silent = true, desc = "Code actions" }))

          map("i", "<C-.>", "<Esc><cmd>lua vim.lsp.buf.code_action()<CR>a",
            vim.tbl_extend("force", opts, { silent = true, desc = "Code actions" }))

          map("n", "<leader>d", vim.diagnostic.open_float, opts)
          map("n", "[d", vim.diagnostic.goto_prev, opts)
          map("n", "]d", vim.diagnostic.goto_next, opts)
        end,
      })

      -- ==========================================================
      -- Navegación / archivo / telescope / árbol / statusline
      -- ==========================================================
      map("n", "<leader>h", "<C-w>h")
      map("n", "<leader>l", "<C-w>l")
      map("n", "<leader>j", "<C-w>j")
      map("n", "<leader>k", "<C-w>k")

      map("n", "<leader>w", ":w<CR>")
      map("n", "<leader>q", ":q<CR>")

      local ok, telescope = pcall(require, "telescope.builtin")
      if ok then
        map("n", "<leader>ff", telescope.find_files)
        map("n", "<leader>fg", telescope.live_grep)
        map("n", "<leader>fb", telescope.buffers)
      end

      local ok2, _ = pcall(require, "nvim-tree")
      if ok2 then
        local api = require("nvim-tree.api")

        local function toggle_tree_with_focus()
          if api.tree.is_visible() then
            api.tree.close()
            vim.cmd("wincmd p")
            if is_editable_buffer(0) then
              vim.cmd("startinsert")
            end
          else
            -- si veníamos de insert, hay que salir antes de enfocar el
            -- árbol: ahí se necesita modo Normal para navegar/crear
            vim.cmd("stopinsert")
            api.tree.open()
            api.tree.focus()
          end
        end

        require("nvim-tree").setup({
          view = {
            side = "right",
            width = 35,
          },
          on_attach = function(bufnr)
            -- Mapeos por defecto de nvim-tree (todos en modo Normal):
            --   a       crear archivo (o carpeta si el nombre termina en
            --           "/"; escribir "foo/bar.txt" crea "foo/" también)
            --   d       borrar         r   renombrar
            --   x/c/p   cortar/copiar/pegar
            --   <CR>/o  abrir o expandir/colapsar carpeta
            -- Sin esto, el árbol no tenía NINGÚN bind propio -- por eso
            -- no había forma de crear archivos.
            api.config.mappings.default_on_attach(bufnr)

            -- por si el árbol recibe foco por otra vía (:NvimTreeFocus,
            -- clic, etc.) y no pasa por nuestro toggle_tree_with_focus
            vim.api.nvim_create_autocmd("BufEnter", {
              buffer = bufnr,
              callback = function()
                vim.cmd("stopinsert")
              end,
            })
          end,
        })
        map({ "n", "i" }, "<C-b>", toggle_tree_with_focus)
      end

      local ok3, lualine = pcall(require, "lualine")
      if ok3 then
        lualine.setup({ options = { theme = "tokyonight" } })
      end
    '';
  };
}
