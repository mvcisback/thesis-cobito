{
  description = "PhD thesis as a cob forest — dogfooding cobito";

  inputs.cobito.url = "git+file:///home/mvc/work/llm-literate";

  outputs = { self, cobito }:
    let
      system = "x86_64-linux";
      pkgs = cobito.inputs.nixpkgs.legacyPackages.${system};
      cob = cobito.packages.${system}.cob; # prose + math; no code grammars needed yet
      # The `custom[latexfig]` fence (§6.6) renders Inkscape .pdf_tex figures through
      # LaTeX. Its handler (tools/latexfig) needs pdflatex, pdf2svg, and python3; a
      # lean, pinned texlive with `standalone` keeps the render reproducible.
      texSet = pkgs.texlive.withPackages (ps: with ps; [
        scheme-small standalone xcolor amsmath pgf
      ]);
      figTools = [ texSet pkgs.pdf2svg pkgs.python3 ];
    in {
      # `nix build .#site` weaves the forest to _site/ (cob reads KaTeX from its wrapper).
      packages.${system}.site = pkgs.runCommand "thesis-site" { nativeBuildInputs = figTools; } ''
        cp -r ${self} work && chmod -R +w work && cd work
        # The book is the ordered chapter list woven as one document (page-split
        # at each h1). Add a chapter here to include it.
        ${cob}/bin/cob weave intro.cob prelims.cob dynamics.cob learning.cob taskspecs.cob diss.cob sgs.cob luce-axiom.cob prop-grad.cob bibliographic-notes-30s.cob teaching.cob --out $out
      '';
      packages.${system}.default = cob;
      devShells.${system}.default = pkgs.mkShell { packages = [ cob ]; };
    };
}
