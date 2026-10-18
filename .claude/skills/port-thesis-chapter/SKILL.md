---
name: port-thesis-chapter
description: >
  Port one section or chapter of the LaTeX PhD thesis at /home/mvc/work/thesis
  into the cob literate forest at /home/mvc/work/thesis-forest, then weave,
  verify, publish, and commit. Use for the mechanical, repeatable parts of the
  port. STOP and hand back to the main model when you hit an escalation trigger
  (a LaTeX construct with no cob equivalent, a macro cob/KaTeX cannot express, a
  figure with no usable source, any need to change cob itself).
---

# Porting a thesis section into the cob forest

This is a mechanical transcription job with a tight verify loop. Convert LaTeX to
cob's command-Markdown dialect by the table below, reuse the established recipes
for macros and figures, then weave → verify green → publish → commit. Do **not**
improvise cob features; if a source construct is not in this skill, escalate.

## The setup

- **Source** (read-only): `/home/mvc/work/thesis`, LaTeX (ucbthesis). Chapters in
  `src/{00_intro,10_learning,30_control,40_outro}/*.tex`; each dir rooted by
  `00_root.tex` whose `\input{..}` lines give the file order. `src/macros.tex`
  and `src/math_commands.tex` hold `\newcommand`/`\def`/`\DeclareMathOperator`.
- **Target**: `/home/mvc/work/thesis-forest`, a **plain git + git-LFS** repo (NOT
  jj). One `.cob` per thesis source file. The book is the ordered file list in
  the `site` target of `thesis-forest/flake.nix`.
- **cob binary**: `/home/mvc/work/llm-literate/target/debug/cob` (already built).
- **Weave environment**: every `cob` command runs inside the cobito devShell for
  `COB_KATEX_ASSETS`, and a figure that uses `custom[latexfig]` also needs
  `python3`, `pdf2svg`, and a texlive-with-`standalone` on `PATH`. Use the
  wrapper in "Commands" below verbatim.

## A `.cob` file's shape

- A thesis `\chapter{Title}` → a **new page**: the file starts with `# Title` (an
  h1). One h1 per file for a chapter.
- A file produced by a mid-chapter `\input` (its source starts with `\section`,
  not `\chapter`) → **no h1**: start at `## ...` (h2). In the book weave it merges
  into the preceding chapter's page. (This is how `sgs.cob` joins the DISS page.)
- Headings: `\section`→`##`, `\subsection`→`###`. Flatten `\subsubsection` to
  `###` too (print nesting → flat web nodes); never go past `###` for a taxon.
- Register the new file in `thesis-forest/flake.nix`'s `cob weave … --out $out`
  list, in reading order.

## LaTeX → cob conversion table

| LaTeX | cob |
|---|---|
| `\emph{x}`, `\textit{x}`, `\textsl{x}` | `\emph{x}` |
| `\textbf{x}`, `\textsc{x}`, `{\em x}` | `\strong{x}` |
| `\texttt{x}`, `\verb\|x\|` | `` \code{x} `` |
| `$x$` | `$x$` (unchanged) |
| `$$x$$`, `\[x\]`, `\begin{equation} x \end{equation}` | a display `$$x$$`, or a ```` ```math ```` fence if it needs an `eq:` label |
| ``` ``...'' ``` (curly quotes) | `"..."` |
| `\ref{k}`, `\eqref{k}`, `Fig~\ref{k}` | `\ref{k}` (drop the `Fig~`/`Eq~` word — cob draws "Figure N" etc.) |
| `\cite{k}`, `\cite{k1,k2}` | `\cite{k}`, `\cite{k1,k2}` (unchanged) |
| `\footnote{x}`, `\footnotetext{x}` | `\sidenote{x}` at the reference point |
| `\epigraph{quote}{attrib}`, a chapter-opening quote | a `>` blockquote, then `> — attrib` |
| `\begin{enumerate}` / `\begin{itemize}` | `1.` / `-` Markdown lists |
| `\begin{quote}` | `>` blockquote |
| `\nicefrac{a}{b}` | `\tfrac{a}{b}` |
| `\DeclareMathOperator{\F}{F}` / `\DeclareMathOperator*` | define `\F` as `\operatorname{F}` / `\operatorname*{F}` in a macros fence |

### Theorem-like environments → taxa

A `\begin{ENV}[optional title]\label{k} ... \end{ENV}` becomes a **taxon node**:

```
\taxon{ENV}

### Title {#ns:name}

...body...
```

- `ENV` maps to a taxon name: `theorem`, `lemma`, `proposition`, `corollary`,
  `definition` (also `mddef`), `example`, `remark`, `problem` (an `\mdframed`
  "Problem" box), `observation`, etc. — lowercase.
- Give the heading a short title (invent one from the statement if the source has
  none) and a `{#ns:name}` label (see namespaces below). The label makes it
  referenceable and gives it a node page.
- `definition/theorem/lemma/proposition/corollary/problem` render **boxed**;
  `example/remark` render as a label only. Nothing else to do — CSS handles it.
- `\begin{proof} ... \end{proof}` → plain prose led by `\emph{Proof.}`, inside the
  statement's node (no separate heading).
- An `\mdframed`/`\begin{mdframed}` callout with no theorem inside → a
  `\taxon{remark}` with a short title, or just prose if it is an aside.

### Label namespaces

`sec:` (section) · `def:` (definition) · `thm:` (theorem) · `lem:` · `cor:` ·
`prop:` · `ex:` (example) · `rem:` (remark) · `prob:` (problem) · `fig:` ·
`tbl:` · `eq:` · `alg:` (algorithm). Any heading with a `{#ns:name}` becomes a
node and `\ref{ns:name}` resolves to it — across pages of the same book.

**Chapter-level cross-refs** (`Ch~\ref{ch:foo}`) do NOT resolve (an h1 is a page,
not a label): rewrite them as prose ("the previous chapter", "a later part"). A
`\ref` to a specific def/thm/fig/eq/alg DOES resolve — keep it.

## Macros (notation)

- Collect the `\newcommand`/`\def` the section actually uses (look them up in
  `src/macros.tex` / `src/math_commands.tex`).
- Put them in a **co-located** ```` ```macros \label{def:NAME-notation} ```` fence
  near their first use, with a one-line prose intro then the defs.
- Syntax: 0-ary `\def\name{expansion}`; parametric uses Forester named params
  `\def\name[x]{...\x...}` (cob maps `\x` to KaTeX `#1`). A raw `\def\name#1{...}`
  is **E022** — do not use `#`.
- **Reuse, don't redefine**: in a book weave all chapters share one KaTeX macro
  table, so a macro already defined in an earlier chapter's fence is in scope —
  use it, do not redefine it (redefining risks a clash).
- Known KaTeX adaptations: `\eqdef` → `\stackrel{\text{def}}{=}`; `\concat`
  (centerdot) → `\cdot`; `\DeclareMathOperator` → `\operatorname` (`*` form for
  limits-below); `\textsl` → `\textit`; `\mathop{\mathbb{E}}` → `\mathbb{E}`.
- If a macro will not expand in KaTeX and is not in this list → **escalate**.

## Figures — three cases

First find the source in `/home/mvc/work/thesis/imgs/`. Decide by what exists:

1. **Plain SVG, no LaTeX in its text** (check: `grep -c '\$[^$]*\$' imgs/NAME.svg`
   is 0). Copy it into `thesis-forest/imgs/`, run the **white-background pass**
   (below) if it is a gridworld/DFA/diagram, then a plain fence:
   ````
   ```figure \label{fig:name}
   \caption{...}
   <img src="imgs/NAME.svg" alt="...">
   ```
   ````
2. **An Inkscape `.pdf_tex` figure** (its `.svg` has literal `$...$` in `<text>`,
   i.e. `grep -c` is > 0): copy `NAME.pdf` (LFS) **and** `NAME.pdf_tex` into
   `thesis-forest/imgs/`, then a custom fence whose body is the `.pdf_tex` path:
   ````
   ```custom[latexfig] \label{fig:name}
   \caption{...}
   imgs/NAME.pdf_tex
   ```
   ````
   The handler defines cob's macros and typesets the figure. If pdflatex reports
   an **undefined control sequence** for a macro, that macro is not in cob's defs:
   add it to a `macros` fence (preferred) or escalate.
3. **A matplotlib plot PDF** (`mass_*.pdf` etc., no usable `.svg`/`.pdf_tex`):
   copy the `.pdf` (LFS) and use a custom fence with an **inline** `\includegraphics`:
   ````
   ```custom[latexfig] \label{fig:name}
   \caption{...}
   \includegraphics{imgs/NAME.pdf}
   ```
   ````

`\caption{...}` is always a **leading body line** of the fence, never on the info
line. Figure labels must be unique across the whole book.

### The white-background pass (case 1 only)

Many exported SVGs have transparent cells. Give one a white backdrop in place
(keeps its Inkscape position):

```sh
nix shell nixpkgs#python3 --command python3 - "$f" <<'PY'
import re, sys
f = sys.argv[1]; s = open(f, encoding="utf-8").read()
if 'data-cob-bg' not in s:
    i = s.index('<svg'); gt = s.index('>', i)
    m = re.search(r'viewBox="([-\d.\s]+)"', s)
    if m:
        x, y, w, h = m.group(1).split()
        s = s[:gt+1] + f'<rect data-cob-bg="1" x="{x}" y="{y}" width="{w}" height="{h}" fill="#ffffff"/>' + s[gt+1:]
        open(f, "w", encoding="utf-8").write(s)
PY
```

## STE house style (write all prose this way)

ASD-STE100 Simplified Technical English: short sentences (one idea each, ~20–25
words), active voice, present tense, one meaning per word, approved simple verbs
("make/use/get/give", not "generate/utilise/obtain/provide"), no noun cluster
over three words. Say *why* before *how*. This is a re-authoring for the web, not
a verbatim transcription — tighten the prose, but do not change the math or the
claims.

## Commands — the verify loop

Run from `/home/mvc/work/llm-literate`. `BOOK` is the current ordered file list
(copy it from `thesis-forest/flake.nix`). This wrapper puts the figure toolchain
on PATH; it is harmless when no `custom[latexfig]` figure is present.

```sh
nix develop --override-input seed "path:/tmp/seed010" --command bash -c '
  export PATH="$(nix build --no-link --print-out-paths nixpkgs#python3)/bin:$(nix build --no-link --print-out-paths nixpkgs#pdf2svg)/bin:$(nix build --no-link --print-out-paths --impure --expr "let np=(builtins.getFlake \"git+file:///home/mvc/work/llm-literate\").inputs.nixpkgs; pkgs=import np {system=\"x86_64-linux\";}; in pkgs.texlive.withPackages (ps: with ps; [ scheme-small standalone xcolor amsmath pgf ])" 2>/dev/null | grep -v -- "-man\$" | head -1)/bin:$PATH"
  COB=/home/mvc/work/llm-literate/target/debug/cob
  cd /home/mvc/work/thesis-forest
  BOOK="intro.cob prelims.cob dynamics.cob learning.cob taskspecs.cob diss.cob sgs.cob"   # UPDATE to match flake.nix
  $COB lock $BOOK
  $COB weave $BOOK --out _site > /tmp/weave.log 2>&1; echo "WEAVE_EXIT=$?"
  grep -iE "error|E0[0-9][0-9]|W10[0-6]" /tmp/weave.log | grep -v W107
  tail -1 /tmp/weave.log
'
```

**Pass criteria** — all must hold:
- `WEAVE_EXIT=0`.
- No `error`/`E0xx` lines, and no `W10[0-6]` lines **except W107** (the
  `*.backlinks.html` / `n/<id>.html` W107 lines are a known, harmless false alarm
  — ignore only those).
- `wove N sections … to _site/` printed.
- For each `custom[latexfig]` figure: `grep -c '\$[^$]*\$' _site/imgs/fig-NAME.svg`
  is `0` (the LaTeX actually rendered).

NEVER end a pass/fail check with a pipe into `tail`/`grep` as the arbiter of
success — a pipeline's exit is the last command's, so it hides the real one.
Capture `echo "WEAVE_EXIT=$?"` right after the command, as above.

## Publish and commit

Publish (tailnet-only, overwrites the live copy):
```sh
DEST=/data/fast/pages/tmp/thesis
rm -rf "$DEST" && mkdir -p "$DEST" && cp -r /home/mvc/work/thesis-forest/_site/. "$DEST/"
```

Commit (thesis-forest is git + LFS — stage only sources, never `_site` or
`.cob-cache`; a message file avoids shell-quoting bugs):
```sh
cd /home/mvc/work/thesis-forest
cat > /tmp/msg.txt <<'EOF'
port: <chapter/section> (<file>.cob)

<one short paragraph on what was added>

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
EOF
nix shell nixpkgs#git-lfs --command bash -c '
  git add <the .cob files> cob.lock flake.nix imgs/<new figure sources>
  git commit -q -F /tmp/msg.txt
  git log --oneline -1'
```
Commit per section (or per small group). Do **not** push — the user pushes.
`*.pdf/*.svg/*.png/*.jpg` are LFS-tracked by `.gitattributes`; `.pdf_tex` is plain
text.

## Escalate to the main model (STOP, do not guess) when

- A LaTeX construct has no entry in this skill and no obvious cob fence/taxon
  (e.g. a `wrapfigure` layout, a `subfigure` grid, a `tikzpicture` drawn inline, a
  `tabular` that is not a simple pipe table, `\begin{align}` multi-line you are
  unsure how to render).
- A macro will not expand in KaTeX (E022) and is not a known adaptation.
- A figure has no plain `.svg`, no `.pdf_tex`, and no plot `.pdf` — or `latexfig`
  fails with a LaTeX error you cannot fix by adding a macro.
- The weave errors in a way that is not an obvious typo you introduced.
- Anything would require changing cob itself (`/home/mvc/work/llm-literate`).
- A cross-reference target does not exist and you cannot tell whether it is a
  not-yet-ported chapter or a genuine mistake.

When you stop, report: the file and section, what you converted, the exact error
or the construct you could not map, and the last green commit.
