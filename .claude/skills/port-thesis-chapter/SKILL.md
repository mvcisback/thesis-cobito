---
name: port-thesis-chapter
description: >
  Port one section or chapter of the LaTeX PhD thesis at /home/mvc/work/thesis
  into the cob literate forest at /home/mvc/work/thesis-forest, then weave,
  verify, publish, and commit. Use for the mechanical, repeatable parts of the
  port. NEVER invent text: every sentence must come from the LaTeX source. A
  chapter is done only when tools/audit-port.py does not flag it. STOP and hand
  back to the main model when you hit an escalation trigger
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
  the `files` list of the `[[document]]` table in `thesis-forest/cob.toml`.
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
- Label the h1 with the thesis's own label so other chapters can link to it:
  `# Title {#ch:name}` for a chapter, `# Title {#part:name}` for a part (use the
  names from the source: `ch:DISS`, `part:learn`). An h2-rooted file needs none.
- Register the new file in the `files` list of the `[[document]]` table in
  `thesis-forest/cob.toml`, in reading order. That list is the only place the book
  order is written; `cob lock` and `cob weave` read it, so they take no file
  arguments.

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
| `Ch~\ref{ch:x}`, `Part~\ref{part:x}` | `\ref{ch:x}{Chapter Title}` / `\ref{part:x}{Part Title}` (the second group is the link text; without it the link reads "Chapter k3f9") |
| `\cite{k}`, `\cite{k1,k2}` | `\cite{k}`, `\cite{k1,k2}` (unchanged) |
| `\footnote{x}`, `\footnotetext{x}` | `\sidenote{x}` at the reference point |
| `\epigraph{quote}{attrib}`, a chapter-opening quote | a `>` blockquote, then `> — attrib` |
| `\begin{enumerate}` / `\begin{itemize}` | `1.` / `-` Markdown lists |
| `\begin{quote}` | `>` blockquote |
| `\nicefrac{a}{b}` | `\tfrac{a}{b}` |
| `\DeclareMathOperator{\F}{F}` / `\DeclareMathOperator*` | define `\F` as `\operatorname{F}` / `\operatorname*{F}` in a macros fence |

### Theorem-like environments → node fences

A `\begin{ENV}[optional title]\label{k} ... \end{ENV}` becomes a **`node` fence**.
The node is exactly the fence: the prose after the environment is not in it.

````
```node[ENV] \label{ns:name}
\title{Optional title}
...the environment body, as command Markdown...
```
````

- `ENV` maps to a taxon name, lowercase: `theorem`, `lemma`, `proposition`,
  `corollary`, `definition` (also `mddef`), `example`, `remark`, `problem` (an
  `\mdframed` "Problem" box), `observation`, and so on.
- The fence holds **only** what is inside the `\begin{ENV}...\end{ENV}`. Put the
  prose that follows the environment *after* the closing fence, as ordinary
  paragraphs. This is the reason the fence exists: a definition must not swallow
  the discussion after it.
- `\label{ns:name}` takes the source label's name with a node namespace (see
  below). Without a label the node has no id, no page, and cannot be referenced.
  Label every environment that the source labels, and any that the source refers to.
- `\title{...}` is the environment's optional title (`\begin{theorem}[Pumping]`).
  Leave it out when the source has none. **Do not invent a title.**
- `definition/theorem/lemma/proposition/corollary/problem` render **boxed**;
  `example/remark` render as a label only. CSS does this; you do nothing.
- `\begin{proof} ... \end{proof}` belongs to its statement: put it **inside the
  statement's fence**, after the statement, as a paragraph led by `\emph{Proof.}`.
- The body is full command Markdown: math, lists, `\sidenote`, `\cite`, `\ref`. A
  heading inside is an error. A fence inside a fence needs the outer one to have
  more backticks (four).
- An `\mdframed` callout with no theorem inside is a `node[remark]` if the source
  states a result or definition, or plain prose if it is an aside.
- The older form `\taxon{ENV}` before a `###` heading still works, but it makes the
  node run to the next heading. Use it only for a *section* that really is the node
  (the whole subsection is the definition's discussion). Prefer the fence.

### Label namespaces

`sec:` (section) · `def:` (definition) · `thm:` (theorem) · `lem:` · `cor:` ·
`prop:` · `ex:` (example) · `rem:` (remark) · `prob:` (problem) · `fig:` ·
`tbl:` · `eq:` · `alg:` (algorithm). A `node` fence or a heading with a
`{#ns:name}` becomes a node and `\ref{ns:name}` resolves to it — across pages of the
same book. A `node` fence label must be a node namespace, never `fig:`/`tbl:`/`eq:`/`alg:`.

**Chapter and part refs resolve** when the h1 carries a `ch:`/`part:` label (see
"A `.cob` file's shape"). Keep every `Ch~\ref{ch:foo}` and `Part~\ref{part:foo}`
as a real link. A `\ref` to a def/thm/fig/eq/alg resolves too. Only rewrite a ref
as prose if its target is in a chapter that is not ported yet; then leave a note
in your report.

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
3. **A TikZ figure** (the source has a `tikzpicture`, or `\input{imgs/x}` of a
   `.tex`/`.pgf` file). Copy the `.tex`/`.pgf` into `thesis-forest/imgs/` and use
   the `tikzfig` handler (no LaTeX install needed):
   ````
   ```custom[tikzfig] \label{fig:name}
   \caption{...}
   imgs/NAME.tex
   ```
   ````
   An inline `\begin{tikzpicture}...` body also works. A `figure*` with
   `subfigure` panels is flattened to minipages. If TeX reports an undefined
   control sequence, port that macro into a `macros` fence; if it reports an
   unknown TikZ key or library, escalate.
4. **A matplotlib plot PDF** (`mass_*.pdf` etc., no usable `.svg`/`.pdf_tex`):
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

## Fidelity rules (the port is judged against the source)

1. **Port, do not summarize or invent.** Every sentence, definition, theorem,
   proof, example, equation, figure, and citation in the source section must appear
   in the port, in the same order. STE tightening may shorten a sentence; it must
   not drop a claim.
2. **No filler.** Never write a transition or heading the source does not have,
   such as "In this section, we describe ...", or a generic "Introduction" /
   "Conclusions" heading. If a source section is too long to finish, port the part
   you can, stop at a section boundary, and say what is left. An unported section
   is honest; a placeholder is a defect.
3. **Use the source's headings, labels, and chapter titles**, even when you shorten
   the text under them.
4. **Run the audit** before you commit a chapter:
   `nix shell nixpkgs#python3 --command python3 tools/audit-port.py --verbose`.
   It flags `THIN`, `NODES`, `FIGS`, `MATH`, `CITES`, and `PLACEHOLDER`, and lists
   missing headings and uncited keys. A chapter is done when it is not flagged.
5. **Fence syntax is exactly** ```` ```kind \label{ns:name} ```` — kinds `figure`,
   `table`, `math`, `algorithm`, `node[taxon]`, `macros`, `verbatim`, `html-escape`, and
   `custom[handler]`. A pandoc attribute block such as ```` ```{.figure #fig:x} ````
   is an error. A `\remark{...}` command does not exist; use a `\taxon{remark}`
   node.

## STE house style (write all prose this way)

ASD-STE100 Simplified Technical English: short sentences (one idea each, ~20–25
words), active voice, present tense, one meaning per word, approved simple verbs
("make/use/get/give", not "generate/utilise/obtain/provide"), no noun cluster
over three words. Say *why* before *how*. This is a re-authoring for the web, not
a verbatim transcription — tighten the prose, but do not change the math or the
claims.

## Commands — the verify loop

Run from `/home/mvc/work/llm-literate`. The book is read from `cob.toml`, so
`cob lock` and `cob weave` take no file arguments. This wrapper puts the figure
toolchain on PATH (python3, pdf2svg, node, texlive); it is harmless when no
`custom` figure is present. The `tikzfig` handler needs `npm ci` once in
`tools/tikzfig`.

```sh
nix develop --override-input seed "path:/tmp/seed010" --command bash -c '
  export PATH="$(nix build --no-link --print-out-paths nixpkgs#python3)/bin:$(nix build --no-link --print-out-paths nixpkgs#pdf2svg)/bin:$(nix build --no-link --print-out-paths --impure --expr "let np=(builtins.getFlake \"git+file:///home/mvc/work/llm-literate\").inputs.nixpkgs; pkgs=import np {system=\"x86_64-linux\";}; in pkgs.texlive.withPackages (ps: with ps; [ scheme-small standalone xcolor amsmath pgf ])" 2>/dev/null | grep -v -- "-man\$" | head -1)/bin:$PATH"
  COB=/home/mvc/work/llm-literate/target/debug/cob
  cd /home/mvc/work/thesis-forest
  $COB lock
  $COB weave --out _site > /tmp/weave.log 2>&1; echo "WEAVE_EXIT=$?"
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
  git add <the .cob files> cob.lock cob.toml imgs/<new figure sources>
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
