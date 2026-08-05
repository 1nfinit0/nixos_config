{ config, pkgs, lib, ... }:
{
  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "$HOME/.local/share/micromamba";
  };

  programs.zsh = {
    enable = true;
    # -------------------------
    # Features base
    # -------------------------
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # -------------------------
    # Completion: cachear compinit (evita compaudit + scan completo de fpath en cada terminal)
    # -------------------------
    completionInit = ''
      autoload -Uz compinit
      for dump in ''${ZDOTDIR:-$HOME}/.zcompdump(N.mh+24); do
        compinit
      done
      compinit -C
    '';

    # -------------------------
    # History
    # -------------------------
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # -------------------------
    # Aliases (incluye los tuyos)
    # -------------------------
    shellAliases = {
      l = "eza -lh --icons --sort=modified --no-permissions --no-user --no-filesize";
      ll = "eza -lh --icons --sort=modified";
      la = "eza -lah --icons --sort=modified";
      lt = "eza --tree";
      cat = "bat --plain";
      grep = "rg";
      icat = "kitty +kitten icat";
      rebuild = "sudo nixos-rebuild switch --flake .";
      build = "sudo nixos-rebuild build --flake .";
      update = "nix flake update && sudo nixos-rebuild switch --flake .";
      check = "nix flake check";
    };

    # -------------------------
    # Plugins
    # -------------------------
    plugins = [
      { name = "fzf-tab"; src = pkgs.zsh-fzf-tab; }
      { name = "history-substring-search"; src = pkgs.zsh-history-substring-search; }
      { name = "autopair"; src = pkgs.zsh-autopair; }
      { name = "you-should-use"; src = pkgs.zsh-you-should-use; }
    ];

    # -------------------------
    # Init
    # -------------------------
    initContent = lib.mkMerge [
      # Tiene que correr ANTES que compinit y todo lo demás
      (lib.mkOrder 500 ''
        # Powerlevel10k instant prompt
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')

      (lib.mkOrder 1000 ''
        export EDITOR=nvim
        # Powerlevel10k
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

        # zoxide (hook generado en build-time, no en cada terminal)
        source ${pkgs.runCommand "zoxide-init-zsh" {} ''
          ${pkgs.zoxide}/bin/zoxide init zsh > $out
        ''}

        # completions tuning
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu select

        # navegación de historial
        bindkey "^[[A" history-substring-search-up
        bindkey "^[[B" history-substring-search-down

        # -------------------------
        # TU KEYBINDING LEGACY (MANTENIDO)
        # -------------------------
        bindkey -e
        # inicio / fin de línea
        bindkey "^[[H" beginning-of-line
        bindkey "^[[F" end-of-line
        # delete
        bindkey "^[[3~" delete-char
        # mover por palabras (Ctrl + flechas)
        bindkey "^[[1;5D" backward-word
        bindkey "^[[1;5C" forward-word
        # modo emacs
        bindkey -e

        # Micromamba: carga diferida, solo se inicializa la primera vez que lo invocas
        micromamba() {
          unfunction micromamba
          eval "$(command micromamba shell hook --shell zsh)"
          micromamba "$@"
        }
      '')
    ];
  };
}
