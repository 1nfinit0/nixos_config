{ pkgs, ... }:
{
  home.packages = with pkgs; [
    texlab
    pandoc
    (texlive.combine {
      inherit (texlive)
        scheme-medium
        # Idioma
        babel-spanish
        collection-langspanish
        # Matemáticas
        amsfonts
        cancel
        eulervm
        # Gráficos
        pgf
        pgfplots
        tcolorbox
	tikzfill
        # Estilo / formato
        fancyhdr
        titlesec
        titling
        tocloft
        # Referencias
        hyperref
        tocbibind
        # Utilidades
        latexmk
	microtype
	xurl
	pdfcol
	listingsutf8
	sectsty
	enumitem;
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
