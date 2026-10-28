{
  description = "PhD thesis as a cob forest — dogfooding cobito";

  # The public GitHub mirror, not the local checkout: this flake must evaluate
  # on a machine (or CI runner) that has never seen /home/mvc/work/llm-literate.
  # During active cobito development, override it back to a local checkout:
  # `nix build --override-input cobito path:/home/mvc/work/llm-literate`.
  inputs.cobito.url = "github:mvcisback/cobito";
  # cobito's own flake needs a `seed` (a pinned tangled snapshot, §13) to
  # bootstrap-compile; its default points at the private self-hosted forge over
  # ssh, which CI cannot reach. Redirect it to the same tag on the public
  # mirror — keep this in sync with cobito/flake.nix's own `inputs.seed`.
  inputs.cobito.inputs.seed = {
    url = "github:mvcisback/cobito/v0.1.2";
    flake = false;
  };

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
      # The `custom[tikzfig]` fence renders TikZ with a WebAssembly TeX engine
      # (node-tikzjax). Its npm dependencies come from the lockfile, so the render
      # needs no network in the sandbox.
      tikzModules = pkgs.importNpmLock.buildNodeModules {
        npmRoot = ./tools/tikzfig;
        inherit (pkgs) nodejs;
      };
      figTools = [ texSet pkgs.pdf2svg pkgs.python3 pkgs.nodejs ];
    in {
      packages.${system} = {
        # `nix build .#site` weaves the forest to a directory (cob reads KaTeX from
        # its wrapper).
        site = pkgs.runCommand "thesis-site" { nativeBuildInputs = figTools; } ''
          cp -r ${self} work && chmod -R +w work && cd work
          ln -s ${tikzModules}/node_modules tools/tikzfig/node_modules
          # The book is the `files` list of the [[document]] table in cob.toml: the
          # reading order is written there and nowhere else. Add a chapter there.
          ${cob}/bin/cob weave --locked --out $out
        '';
        default = cob;
      };
      devShells.${system}.default = pkgs.mkShell { packages = [ cob ]; };
    };
}
