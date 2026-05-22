{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "tobi";
        email = "noggnzzz@gmail.com";
      };

      init.defaultBranch = "master";
      pull.rebase = false;
      core.editor = "nano";
      color.ui = true;

      push.autoSetupRemote = true;

      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        cm = "commit -m";
        lg = "log --oneline --graph --decorate --all";
      };
    };

    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv"
      ".env"
      "result"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
