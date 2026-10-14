{
  description = "PhD thesis as a cob forest — dogfooding cobito";

  inputs.cobito.url = "git+file:///home/mvc/work/llm-literate";

  outputs = { self, cobito }:
    let
      system = "x86_64-linux";
      pkgs = cobito.inputs.nixpkgs.legacyPackages.${system};
      cob = cobito.packages.${system}.cob; # prose + math; no code grammars needed yet
    in {
      # `nix build .#site` weaves the forest to _site/ (cob reads KaTeX from its wrapper).
      packages.${system}.site = pkgs.runCommand "thesis-site" { } ''
        cp -r ${self} work && chmod -R +w work && cd work
        ${cob}/bin/cob weave intro.cob --out $out
      '';
      packages.${system}.default = cob;
      devShells.${system}.default = pkgs.mkShell { packages = [ cob ]; };
    };
}
