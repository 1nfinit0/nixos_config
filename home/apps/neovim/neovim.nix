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
      dressing-nvim
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

      -- algunos ftplugin/indent que trae Neovim (el de Java, por
      -- ejemplo) fijan su propio shiftwidth/tabstop apenas detectan el
      -- filetype (Java: 4 por defecto), pisando lo de arriba. Esto lo
      -- regresa a tu preferencia de 2 espacios sin importar el lenguaje.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          vim.bo.tabstop = 2
          vim.bo.shiftwidth = 2
          vim.bo.softtabstop = 2
          vim.bo.expandtab = true
        end,
      })

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
      -- 2) Shift+flecha entra a Visual y extiende la selección; con
      --    Ctrl selecciona por palabra, con Ctrl+Home/End selecciona
      --    hasta el inicio/fin del documento.
      -- 3) La terminal no puede detectar "soltar Shift" (no hay evento
      --    de key-up para modificadores), así que se usa la misma
      --    combinación SIN shift como señal de "ya solté shift": si
      --    estás en Visual y la presionas, se colapsa la selección
      --    donde estaba (sin mover más) y vuelves a insert ahí mismo.
      -- 4) Fuera de una selección, esas mismas combinaciones sin shift
      --    simplemente mueven el cursor (por carácter, palabra, o al
      --    inicio/fin del documento) y, si quedaste en Normal por algún
      --    motivo (Esc manual, :w, una acción de LSP), regresan a
      --    insert -- Normal nunca queda "pegado" sin pedirlo tú.

      local function visual_move(motion)
        -- :normal! NO traduce notaciones como <C-f> por sí solo (a
        -- diferencia de un mapeo normal); hay que traducirlas primero
        -- a los bytes reales para que motions con Ctrl funcionen aquí.
        local keys = vim.api.nvim_replace_termcodes(motion, true, false, true)
        return function()
          vim.cmd("normal! v")
          vim.cmd("normal! " .. keys)
        end
      end

      local function move_and_insert(motion)
        return function()
          vim.cmd("normal! " .. motion)
          -- solo "editar" si el buffer actual es realmente editable
          -- (en nvim-tree, quickfix, etc. la combinación debe quedarse
          -- como simple movimiento, sin forzar insert)
          if is_editable_buffer(0) then
            vim.cmd("startinsert")
          end
        end
      end

      -- Selección por unidad: carácter (Shift+flecha), palabra
      -- (Ctrl+Shift+izq/der) y documento completo (Ctrl+Shift+Home/End).
      --
      -- Sobre el "+1 carácter de más" al entrar desde Insert: al salir
      -- de Insert, Neovim retrocede el cursor una columna (así funciona
      -- <Esc> siempre que no estés en la columna 0). Para una selección
      -- hacia la IZQUIERDA eso cae justo donde debía empezar. Para una
      -- hacia la DERECHA hay que compensar ese retroceso con una "l" de
      -- más ANTES de entrar a Visual -- si no, la selección arranca
      -- incluyendo el carácter que ya habías escrito (el bug reportado).
      -- Para un solo carácter (h/l) ese único paso ya lo da <Esc> (o la
      -- "l" de compensación), así que no se repite con la motion; para
      -- palabra/documento (b/w, gg/G) sí se aplica la motion completa.
      local selection_units = {
        {
          keys  = { left = { "<S-Left>" },   right = { "<S-Right>" } },
          left  = { motion = "h", atomic = true },
          right = { motion = "l", atomic = true },
        },
        {
          -- <C-S-...> por si algún día liberas esa combinación en la
          -- terminal/Hyprland; <M-S-...> (Alt+Shift) como respaldo que
          -- casi nunca está tomado por el WM ni la terminal.
          keys  = { left = { "<C-S-Left>", "<M-S-Left>" }, right = { "<C-S-Right>", "<M-S-Right>" } },
          left  = { motion = "b" },
          right = { motion = "w" },
        },
        {
          keys  = { left = { "<C-S-Home>" }, right = { "<C-S-End>" } },
          left  = { motion = "gg" },
          right = { motion = "G" },
        },
      }

      for _, unit in ipairs(selection_units) do
        for _, side in ipairs({ "left", "right" }) do
          local motion = unit[side].motion
          local atomic = unit[side].atomic

          -- Insert -> Visual (ver la nota de arriba). Importante: SIN
          -- expr = true. El rhs ya es la secuencia de teclas literal;
          -- con expr = true Neovim la evaluaría como Vimscript y truena
          -- con "E15: Invalid expression".
          local insert_rhs
          if side == "left" then
            insert_rhs = atomic and "<Esc>v" or ("<Esc>v" .. motion)
          else
            insert_rhs = atomic and "<Esc>lv" or ("<Esc>lv" .. motion)
          end

          for _, key in ipairs(unit.keys[side]) do
            -- Normal -> Visual: el cursor ya está sobre un carácter
            -- real, sin el desfase de Insert, así que siempre v + motion.
            map("n", key, visual_move(motion))
            map("i", key, insert_rhs)
            -- Visual: seguir extendiendo mientras "sigues con shift"
            map("v", key, motion)
          end
        end
      end

      -- Arriba/abajo (línea) y Shift+Fn+flecha (página visible, lo
      -- típico): el desfase de columna que deja <Esc> es perpendicular
      -- al eje vertical, así que aquí SIEMPRE hace falta la compensación
      -- de "l" (a diferencia de horizontal, donde solo hacía falta para
      -- un lado) -- si no, la selección arranca en la columna de un
      -- carácter antes del cursor real, en vez de la columna exacta.
      -- <C-b>/<C-f> son los motions de Vim para retroceder/avanzar una
      -- pantalla completa.
      local vertical_selection = {
        ["<S-Up>"] = "k", ["<S-Down>"] = "j",
        ["<S-PageUp>"] = "<C-b>", ["<S-PageDown>"] = "<C-f>",
      }
      for key, motion in pairs(vertical_selection) do
        map("n", key, visual_move(motion))
        map("i", key, "<Esc>lv" .. motion)
        map("v", key, motion)
      end

      -- Visual -> Insert ("soltaste shift" en cualquiera de las
      -- combinaciones de arriba): colapsa la selección donde estaba
      -- -- sin mover más -- y sigue editando ahí. Mismo motivo que
      -- arriba: nada de expr = true aquí.
      for _, key in ipairs({
        "<Left>", "<Right>", "<Up>", "<Down>",
        "<C-Left>", "<C-Right>", "<C-Home>", "<C-End>",
        "<PageUp>", "<PageDown>",
      }) do
        map("v", key, "<Esc>i")
      end

      -- Flechas solas (sin shift, sin selección activa): si quedaste
      -- en Normal, mueven y regresan a insert.
      map("n", "<Left>",  move_and_insert("h"))
      map("n", "<Right>", move_and_insert("l"))
      map("n", "<Up>",    move_and_insert("k"))
      map("n", "<Down>",  move_and_insert("j"))

      -- Ctrl+flecha / Ctrl+Home / Ctrl+End sin shift: mismo trato, pero
      -- moviendo por palabra o al inicio/fin del documento.
      local plain_ctrl_moves = {
        ["<C-Left>"] = "b", ["<C-Right>"] = "w",
        ["<C-Home>"] = "gg", ["<C-End>"] = "G",
        -- "{"/"}" son los motions nativos de Vim para saltar entre
        -- bloques separados por una línea en blanco (párrafos de texto,
        -- bloques de código, lo que sea) -- justo lo que pediste.
        ["<C-Up>"] = "{", ["<C-Down>"] = "}",
      }

      for key, motion in pairs(plain_ctrl_moves) do
        map("n", key, move_and_insert(motion))
        -- <C-o> ejecuta un solo comando de Normal (aquí, el motion
        -- completo, aunque sea de dos teclas como "gg") y regresa a
        -- insert sin salir de él.
        map("i", key, "<C-o>" .. motion)
      end

      -- En Visual, Ctrl+Arriba/Abajo extiende la selección hasta el
      -- siguiente/anterior bloque -- a diferencia de Ctrl+flecha/
      -- Home/End (que cancelan la selección, ver la lista de abajo),
      -- aquí sí tiene sentido "seleccionar el bloque completo" de un jalón.
      map("v", "<C-Up>",   "{")
      map("v", "<C-Down>", "}")

      -- desplazamiento de pantalla
      local function scroll_line_up()
        vim.cmd("normal! <C-y>")
      end

      local function scroll_line_down()
        vim.cmd("normal! <C-e>")
      end

      -- <C-Up>/<C-Down> ahora son navegación por bloques (ver
      -- plain_ctrl_moves más arriba); el scroll de pantalla se queda
      -- solo en <C-k>/<C-j>.
      map("n", "<C-k>",    scroll_line_up,   { silent = true })
      map("n", "<C-j>",    scroll_line_down, { silent = true })
      map("v", "<C-k>",    scroll_line_up,   { silent = true })
      map("v", "<C-j>",    scroll_line_down, { silent = true })
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
      -- (el Visual->Insert de <PageUp>/<PageDown> ya quedó cubierto
      -- arriba, junto con el resto de teclas que "cancelan" selección)
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

      -- Seleccionar todo (Normal e Insert)
      map("n", "<C-a>", "ggVG", { silent = true, desc = "Seleccionar todo" })
      map("i", "<C-a>", "<Esc>ggVG", { silent = true, desc = "Seleccionar todo" })

      -- Navegación entre pestañas.
      -- Kitty debe enviar secuencias CSI-u distintas para Ctrl+Tab y
      -- Ctrl+Shift+Tab; los terminales clásicos suelen colapsarlas a Tab.
      local ctrl_tab = "\27[9;5u"
      local ctrl_shift_tab = "\27[9;6u"
      
      map({ "n", "i", "v" }, ctrl_tab, "<cmd>tabnext<CR>", {
        silent = true,
        desc = "Pestaña siguiente",
      })

      map({ "n", "i", "v" }, ctrl_shift_tab, "<cmd>tabprevious<CR>", {
        silent = true,
        desc = "Pestaña anterior",
      })

      -- Respaldo con la notación estándar: si Neovim SÍ traduce el
      -- protocolo extendido de kitty a <C-Tab>/<C-S-Tab> en vez de
      -- darte el byte crudo de arriba, esto cubre ese caso también
      -- (uno de los dos disparará, no hay conflicto entre ambos).
      map({ "n", "i", "v" }, "<C-Tab>", "<cmd>tabnext<CR>", {
        silent = true,
        desc = "Pestaña siguiente",
      })

      map({ "n", "i", "v" }, "<C-S-Tab>", "<cmd>tabprevious<CR>", {
        silent = true,
        desc = "Pestaña anterior",
      })

      -- portapapeles del sistema
      map("v", "d", '"+d')
      map("v", "x", '"+d')
      map("v", "<BS>", '"+d')
      map("v", "<Del>", '"+d')
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
        completion = {
          autocomplete = false,
        },
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

      -- Menú de selección de Neovim con navegación por flechas.
      -- dressing.nvim proporciona una interfaz compatible para code actions.
      require("dressing").setup({
        select = {
          enabled = true,
          backend = { "builtin" },
        },
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
          map({ "n", "v" }, "<leader>cf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)

          -- comando con ":" (distinto del <leader>cf de arriba, y del
          -- ":cf"/":cfile" que ya trae Vim por defecto)
          vim.api.nvim_create_user_command("Format", function()
            vim.lsp.buf.format({ async = true })
          end, {})

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
          actions = {
            open_file = {
              -- al escoger un archivo (Enter/o), el árbol se cierra solo;
              -- <C-b> lo vuelve a abrir cuando lo necesites
              quit_on_open = true,
            },
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

            -- Ctrl+Enter abre el archivo en una pestaña nueva.
            vim.keymap.set("n", "<C-CR>", api.node.open.tab, {
              buffer = bufnr,
              silent = true,
              desc = "Abrir en nueva pestaña",
            })

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
