{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zathura
    texlab

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

        # Estilo / formato
        fancyhdr
        titlesec
        titling
        tocloft

        # Referencias
        hyperref
        tocbibind

        # Utilidades
        latexmk;
    })
  ];
}
