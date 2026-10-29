# thesis-forest — agent notes

PhD thesis ported into a cob literate forest. Porting procedure lives in
`.claude/skills/port-thesis-chapter/SKILL.md`.

## The book

The book is the `files` list of the `[[document]]` table in `cob.toml`. Its order
is the reading order, and it is written nowhere else: `cob lock` and `cob weave`
read it when given no file arguments, and so does `nix build .#site`. When you
add a `.cob`, add it there, in reading order.

`thesis.cob` is the root. It is the first page: the title page, dedication,
abstract, acknowledgements, a contents list, and a "main ideas" section that
transcludes key nodes from the chapters.

Every chapter and part has a label on its h1 — `# Title {#ch:name}` or
`# Title {#part:name}` — using the thesis's own label (`ch:DISS`, `part:learn`). Use
`\ref{ch:name}` in prose, or `\ref{ch:name}{Title}` for a link that shows the
title. This restores the thesis's `Ch~\ref{...}` and `Part~\ref{...}` links.

## Is the port finished? Run the audit

```sh
nix shell nixpkgs#python3 --command python3 tools/audit-port.py --verbose
```

It compares every chapter with its LaTeX source (size, headings, theorem-like
nodes, figures, math, citations, placeholder phrases) and exits 1 if any chapter
is flagged. A port is finished when it exits 0. Do not claim a chapter is ported
until the audit does not flag it. **Never write a section the source does not
have.** A placeholder such as "In this section, we describe ..." is a defect; the
audit flags it as `PLACEHOLDER`.

**Resolved false alarm (kept as a lesson):** an earlier pass of this file
claimed `30_sgs.tex:777`'s `\section{Relaxing the Luce axiom}\label{sec:luce_cegis}`
was unported, reasoning from the audit's heading-fuzzy-match and from a
`\ref{sec:luce_cegis}` grep that came up empty. Both were red herrings — the
content was already ported, three sections ago, into its own files
(`luce-axiom.cob`, `prop-grad.cob`, `bibliographic-notes-30s.cob`, all listed
in `cob.toml` right after `sgs.cob`) under the forest's own label
`sec:luce-axiom`, not the source's `sec:luce_cegis`. The actual gap was much
smaller: four citations missing from already-correct prose
(`DBLP:conf/asplos/Solar-LezamaTBSS06`, `DBLP:journals/acta/JhaS17`,
`DBLP:journals/pieee/Seshia15`, `Vazquez-Chanlatte_Demonstration_Informed_Specification`)
and three prose mentions (`bdd.cob` Contributions, `outro.cob` "Hybrid and
Continuous Dynamics") that could already have been real `\ref{sec:luce-axiom}`
links. Both are fixed. **The lesson:** before writing a chapter off as
unported, `grep -rn` the *forest's own* label namespace for near-miss names —
a chapter can rename a source label and still carry all the content.

## Build and review loop

The flake's `cobito` input tracks the public GitHub mirror
(`github:mvcisback/cobito`). During active cobito development, override it to a
local checkout: `--override-input cobito path:<checkout>`. These commands run
from the repo root with the toolchain on `PATH`:

```sh
COBBIN=$(nix build <cobito checkout>#cob --no-link --print-out-paths)/bin
PYBIN=$(nix build nixpkgs#python3 --no-link --print-out-paths)/bin
SVGBIN=$(nix build nixpkgs#pdf2svg --no-link --print-out-paths)/bin
NODEBIN=$(nix build nixpkgs#nodejs --no-link --print-out-paths)/bin
TEXBIN=$(nix build --impure --no-link --print-out-paths --expr \
  'let np = builtins.getFlake "git+file://<cobito checkout>"; pkgs = np.inputs.nixpkgs.legacyPackages.x86_64-linux; in pkgs.texlive.withPackages (ps: with ps; [ scheme-small standalone xcolor amsmath pgf ])' \
  | grep -v -- '-man$' | head -1)/bin
export PATH="$COBBIN:$PYBIN:$SVGBIN:$NODEBIN:$TEXBIN:$PATH"

nix shell nixpkgs#git-lfs --command bash -c 'git lfs install --local && git lfs pull'   # first time only; pdf/svg figures are LFS
(cd tools/tikzfig && npm ci)                                                            # first time only; the tikzfig handler's dependency

cob lock
cob weave --out _site > /tmp/weave.log 2>&1; echo "WEAVE_EXIT=$?"
grep -iE "error|E0[0-9][0-9]|W10[0-6]" /tmp/weave.log | grep -v W107
```

`nix build .#site` does the same in a sandbox: it takes the npm dependencies from
`tools/tikzfig/package-lock.json`.

Pass criteria: `WEAVE_EXIT=0`, no `error`/`E0xx` lines, no `W10[0-6]` lines except
W107 (backlinks/asset false alarms), and for each `custom[latexfig]` figure
`grep -c '\$[^$]*\$' _site/imgs/fig-NAME.svg` is `0`. Do not pipe a check through
`tail` or `grep` and read its exit code: a pipe hides the real one.

**Trap:** never let a wrapped line of prose start with `- ` (hyphen, space) —
even inside an inline `$...$` math span that continues from the previous
line. Markdown reads a line-initial `- ` as a new list bullet and breaks the
enclosing math span. The failure is `error[E022]: ... expected one of "$",
"\\$", [_]`, reported at `file.cob:1` regardless of the real line — the
position is useless, so this is easy to lose an hour to. Reflow the line (or
move the minus sign off the left margin) instead of debugging the message.

## Publish for review

The drop-box pages area is `/data/fast/pages/pi/` (pi-owned; do not write the
`pages/` root). Publishing the current weave:

```sh
DEST=/data/fast/pages/pi/thesis
rm -rf "$DEST" && mkdir -p "$DEST" && cp -r _site/. "$DEST/"
```

Review URL (tailnet-only): <https://pages.chanlatte.casa/pi/thesis/index.html>

## Figure handlers

Two `custom` fence handlers render figures (cobito §6.6). Both receive the macros
in scope, so a figure typesets in the same notation as the prose. A macro that a
figure needs but no `macros` fence defines is an "undefined control sequence"
error: port it into a co-located `macros` fence (copy its definition from
`../thesis/src/macros.tex`).

- `custom[latexfig]` (`tools/latexfig`): pdflatex then pdf2svg. The body is an
  Inkscape `.pdf_tex` path, or inline LaTeX such as `\includegraphics{...}`.
- `custom[tikzfig]` (`tools/tikzfig`): a WebAssembly TeX engine (`node-tikzjax`),
  no LaTeX install. The body is a TikZ picture, or a path to a `.tex`/`.pgf` file.
  A whole `figure*` with `subfigure` panels is flattened to minipages. Options in
  `cob.toml`: `preamble_file`, `texPackages`, `tikzLibraries`.

## Credentials for LFS

`git lfs pull` talks to `http://192.168.106.1:9223`. The pi credential store
initially held the gitea token as *username* with no password; if LFS auth
fails, ensure `~/.git-credentials` has a URL-shaped line `http://pi:<token>@192.168.106.1:9223`
with a matching `git credential fill` for `protocol=http host=192.168.106.1:9223 username=pi`.

## Commit rules

git + git-LFS repo, plain git (not jj). Stage only sources (`.cob`,
`cob.lock`, `cob.toml`, `flake.nix`, `tools/`, `imgs/` additions); never `_site`,
`node_modules`, or `.cob-cache`. Commit per section; do not push (the maintainer
pushes). Duplicate `{#ns:name}` labels across files make `cob lock` mint wrong
refs — check for duplicates before committing.
