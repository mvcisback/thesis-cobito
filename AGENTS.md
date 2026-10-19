# thesis-forest — agent notes

PhD thesis ported into a cob literate forest. Porting procedure lives in
`.claude/skills/port-thesis-chapter/SKILL.md`.

## Book order

The book is the ordered file list in the `cob weave` line of `flake.nix`. When
you add a `.cob`, add it there too, in reading order.

## Build and review loop (this container)

The flake's `cobito` input points at the fixed path
`/home/mvc/work/llm-literate`, which does not exist in the pi container
(workspace may simply be `/var/lib/pi/cobito`, the mvcisback `cob` clone or a
checked-out copy of the `cobito` repo). All commands below assume you are in
the repo root and build the toolchain from nix:

```sh
COBBIN=$(nix build ../cobito#cob --no-link --print-out-paths)/bin          # or ../cobito#default
PYBIN=$(nix build nixpkgs#python3 --no-link --print-out-paths)/bin
SVGBIN=$(nix build nixpkgs#pdf2svg --no-link --print-out-paths)/bin
TEXBIN=$(nix build --impure --no-link --print-out-paths --expr \
  'let np = builtins.getFlake "git+file:///var/lib/pi/cobito"; pkgs = np.inputs.nixpkgs.legacyPackages.x86_64-linux; in pkgs.texlive.withPackages (ps: with ps; [ scheme-small standalone xcolor amsmath pgf ])' \
  | tail -1)/bin
export PATH="$COBBIN:$PYBIN:$SVGBIN:$TEXBIN:$PATH"

BOOK="intro.cob prelims.cob dynamics.cob learning.cob taskspecs.cob diss.cob sgs.cob luce-axiom.cob prop-grad.cob bibliographic-notes-30s.cob teaching.cob"   # keep in sync with flake.nix

nix shell nixpkgs#git-lfs --command bash -c 'git lfs install --local && git lfs pull'   # first time only; pdf/svg figures are LFS

cob lock $BOOK
cob weave $BOOK --out _site > /tmp/weave.log 2>&1; echo "WEAVE_EXIT=$?"
grep -iE "error|E0[0-9][0-9]|W10[0-6]" /tmp/weave.log | grep -v W107
```

Pass criteria (from the port skill): `WEAVE_EXIT=0`, no `error`/`E0xx`
lines, no `W10[0-6]` lines except W107 (backlinks/asset false alarms), and for
each `custom[latexfig]` figure `grep -c '\$[^$]*\$' _site/imgs/fig-NAME.svg`
is `0`.

## Publish for review

The drop-box pages area is `/data/fast/pages/pi/` (pi-owned; do not write the
`pages/` root). Publishing the current weave:

```sh
DEST=/data/fast/pages/pi/thesis
rm -rf "$DEST" && mkdir -p "$DEST" && cp -r _site/. "$DEST/"
```

Review URL (tailnet-only): <https://pages.chanlatte.casa/pi/thesis/index.html>

NOTE: the review URL is under `pi/`, not `pages/tmp/` as older notes said.

## Credentials for LFS

`git lfs pull` talks to `http://192.168.106.1:9223`. The pi credential store
initially held the gitea token as *username* with no password; if LFS auth
fails, ensure `~/.git-credentials` has a URL-shaped line `http://pi:<token>@192.168.106.1:9223`
with a matching `git credential fill` for `protocol=http host=192.168.106.1:9223 username=pi`.

## Commit rules

git + git-LFS repo, plain git (not jj). Stage only sources (`.cob`,
`cob.lock`, `flake.nix`, `imgs/` additions); never `_site` or `.cob-cache`.
Commit per section; do not push (mixer pushes). Duplicate `{#ns:name}` labels
across files make `cob lock` silently mint wrong refs — check for dups before
committing.
