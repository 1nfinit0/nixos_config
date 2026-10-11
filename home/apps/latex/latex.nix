{ pkgs, ... }:
{
   
  home.packages = with pkgs; [
    texlab
    pandoc
    (texlive.combine {
      inherit (texlive) scheme-full;
    })
  ];

  programs.zathura = {
    enable = true;
    options = {
      synctex = true;
      synctex-editor-command = "code --goto %{input}:%{line}";
    };
  };
}
