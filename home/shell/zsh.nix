{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;

    # -------------------------
    # Features base
    # -------------------------
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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
      l = "eza --icons";
      ll = "eza -lh --icons --sort=modified";
      la = "eza -lah --icons --sort=modified";
      lt = "eza --tree";

      cat = "bat";
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
    # Init (tu estilo antiguo preservado)
    # -------------------------
    initContent = ''
      export EDITOR=nvim

      # Powerlevel10k
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

      # zoxide
      eval "$(zoxide init zsh)"

      # completions tuning
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

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

      # modo emacs (como tu setup antiguo)
      bindkey -e
    '';
  };
}
