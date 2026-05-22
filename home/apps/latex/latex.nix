{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zathura
    texlab
    tectonic

    (texlive.combine {
      inherit (texlive)
        scheme-medium

        # Idioma / encoding
        babel-spanish
        collection-langspanish

        # Matemáticas
        amsmath
        amssymb
        cancel
        eulervm

        # Gráficos
        pgf
        pgfplots
        tikzfill
        graphicx
        caption
        subcaption

        # Estilo / formato
        fancyhdr
        titlesec
        titling
        tocloft
        setspace
        geometry

        # Layout
        array
        multicol
        float
        indentfirst

        # Referencias
        hyperref
        tocbibind

        # Fonts/encoding
        fontenc
        inputenc

        # Utilidades comunes
        latexmk
        xcolor
        tools;
    })
  ];
}
