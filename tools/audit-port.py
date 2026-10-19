#!/usr/bin/env python3
"""Audit the cob port of the thesis against its LaTeX source.

For each chapter (a group of source .tex files and the .cob files that port
them) this compares size, headings, theorem-like nodes, citations, figures and
math, and measures how much of the port's vocabulary is NOT in the source —
invented text shows up as a high "novelty". It prints a table and exits 1 if any
chapter is flagged, so it can gate a port.

Usage: tools/audit-port.py [--thesis DIR] [--verbose]
"""
import argparse
import difflib
import re
import sys
from pathlib import Path

# (name, source files relative to the thesis src dir, ported .cob files)
GROUPS = [
    ("front-matter",    ["abstract.tex"], ["thesis.cob"]),
    ("intro",           ["00_intro/10_intro.tex"], ["intro.cob"]),
    ("concepts",        ["00_intro/20_prelims.tex"], ["prelims.cob"]),
    ("dynamics",        ["00_intro/25_dynamics.tex"], ["dynamics.cob"]),
    ("learning-part",   ["10_learning/00_root.tex"], ["learning.cob"]),
    ("task-specs",      ["10_learning/01_taskspecs.tex", "10_learning/45_tricks.tex",
                         "10_learning/46_neurips.tex"], ["taskspecs.cob"]),
    ("diss-intro",      ["10_learning/02_problem_statement.tex"], ["diss.cob"]),
    ("diss-algorithm",  ["10_learning/30_sgs.tex"],
     ["sgs.cob", "luce-axiom.cob", "prop-grad.cob", "bibliographic-notes-30s.cob"]),
    ("teaching",        ["10_learning/40_teaching.tex"], ["teaching.cob"]),
    ("control-part",    ["30_control/00_root.tex"], ["control.cob"]),
    ("erci",            ["30_control/10_erci.tex"], ["erci.cob"]),
    ("circuits",        ["30_control/30_circuits.tex"], ["circuits.cob"]),
    ("bdd",             ["30_control/20_bdd_encoding.tex"], ["bdd.cob"]),
    ("outro",           ["40_outro/00_root.tex"], ["outro.cob"]),
]

ENVS = r"theorem|lemma|proposition|corollary|definition|mddef|example|remark|problem|claim|observation"
STUB = re.compile(
    r"\bIn this (section|chapter), we (describe|discuss|introduce|present)\b"
    r"|\bWe now (discuss|describe|show how)\b|\bprovides? a compact and efficient\b",
    re.I)


def read(p):
    try:
        return Path(p).read_text(encoding="utf-8", errors="replace")
    except FileNotFoundError:
        return ""


def mask_dollars(s):
    return s.replace("\\$", " ")


def strip_tex(s):
    s = mask_dollars(s)
    s = re.sub(r"(?<!\\)%.*", "", s)
    s = re.sub(r"\\begin\{(equation|align|eqnarray|displaymath|gather|multline)\*?\}.*?\\end\{\1\*?\}",
               " ", s, flags=re.S)
    s = re.sub(r"\$\$.*?\$\$|\\\[.*?\\\]|\$[^$]*\$", " ", s, flags=re.S)
    return s


def strip_cob(s):
    s = mask_dollars(s)
    s = re.sub(r"```macros.*?```", " ", s, flags=re.S)
    s = re.sub(r"```(math|algorithm).*?```", " ", s, flags=re.S)
    s = re.sub(r"\$\$.*?\$\$|\$[^$]*\$", " ", s, flags=re.S)
    s = re.sub(r"\{#[^}]*\}", " ", s)
    return s


def words(s):
    s = re.sub(r"\\[a-zA-Z]+\*?", " ", s)
    s = re.sub(r"[{}\[\]\\_^#>*`|~]", " ", s)
    return [w.lower() for w in re.findall(r"[A-Za-z][A-Za-z'-]+", s)]


def norm(t):
    t = re.sub(r"\\[a-zA-Z]+\*?", " ", t)
    return re.sub(r"[^a-z0-9 ]", "", t.lower()).strip()


def src_headings(s):
    out = []
    for m in re.finditer(r"\\(?:chapter|section|subsection|subsubsection)\*?\{((?:[^{}]|\{[^{}]*\})*)\}", s):
        out.append(norm(m.group(1)))
    return [h for h in out if h]


def cob_headings(s):
    out = []
    for line in s.splitlines():
        m = re.match(r"#{1,6}\s+(.*?)(\s*\{#[^}]*\})?\s*$", line)
        if m:
            out.append(norm(m.group(1)))
    return [h for h in out if h]


def cites(s, src):
    keys = set()
    pat = r"\\cite[a-z]*\*?(?:\[[^\]]*\])*\{([^}]*)\}"
    for m in re.finditer(pat, s):
        keys.update(k.strip() for k in m.group(1).split(",") if k.strip())
    return keys


def count_nodes_src(s):
    return len(re.findall(r"\\begin\{(?:%s)\}" % ENVS, s))


def count_nodes_cob(s):
    # A node is a `\\taxon{..}` heading or a `node[..]` fence (cobito §10).
    return len(re.findall(r"^\\taxon\{|^`{3,}node\[", s, flags=re.M))


def count_figs_src(s):
    return len(re.findall(r"\\includegraphics|\\import\{[^}]*\}\{[^}]*(?:pdf_tex|pgf)|\\input\{[^}]*(?:pdf_tex|pgf)"
                          r"|\\begin\{tikzpicture\}", s))


def count_figs_cob(s):
    return len(re.findall(r"^```\{?\.?(?:figure|custom|algorithm)|^```(?:figure|custom|algorithm)", s, flags=re.M))


def count_math(s):
    s = mask_dollars(s)
    return len(re.findall(r"\$\$|\\begin\{(?:equation|align)", s)) + s.count("$") // 2


def match_headings(src_h, cob_h):
    missing = []
    for h in src_h:
        best = max((difflib.SequenceMatcher(None, h, c).ratio() for c in cob_h), default=0)
        if best < 0.6:
            missing.append(h)
    return missing


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--thesis", default=str(Path.home() / "work/thesis"))
    ap.add_argument("--verbose", action="store_true")
    a = ap.parse_args()
    src_dir = Path(a.thesis) / "src"
    forest = Path(__file__).resolve().parent.parent

    # Vocabulary of the whole source, for the novelty measure. thesis.tex adds the
    # title page and acknowledgements, which the front matter ports.
    all_src_words = set(words(strip_tex(read(Path(a.thesis) / "thesis.tex"))))
    for _, srcs, _ in GROUPS:
        for f in srcs:
            all_src_words.update(words(strip_tex(read(src_dir / f))))

    hdr = f"{'chapter':16}{'src w':>7}{'port w':>8}{'ratio':>7}{'nodes':>9}{'figs':>8}{'math':>9}{'cites':>9}{'novel':>7}  flags"
    print(hdr)
    print("-" * len(hdr))
    bad = 0
    detail = []
    for name, srcs, cobs in GROUPS:
        st = "\n".join(read(src_dir / f) for f in srcs)
        ct = "\n".join(read(forest / f) for f in cobs)
        sw, cw = words(strip_tex(st)), words(strip_cob(ct))
        ratio = len(cw) / len(sw) if sw else 0
        novel_words = [w for w in cw if len(w) >= 5 and w not in all_src_words]
        novelty = len(novel_words) / max(1, sum(1 for w in cw if len(w) >= 5))
        sn, cn = count_nodes_src(st), count_nodes_cob(ct)
        sf, cf = count_figs_src(st), count_figs_cob(ct)
        sm, cm = count_math(st), count_math(ct)
        sc, cc = cites(st, True), cites(ct, False)
        miss_h = match_headings(src_headings(st), cob_headings(ct)) if cobs else src_headings(st)
        stub = bool(STUB.search(ct))
        flags = []
        if not cobs:
            flags.append("NOT PORTED")
        else:
            if ratio < 0.55:
                flags.append("THIN")
            if novelty > 0.30:
                flags.append("INVENTED?")
            if stub:
                flags.append("PLACEHOLDER")
            if sn and cn < 0.5 * sn:
                flags.append("NODES")
            if sf and cf < 0.5 * sf:
                flags.append("FIGS")
            if sm > 8 and cm < 0.4 * sm:
                flags.append("MATH")
            if sc and len(cc) < 0.5 * len(sc):
                flags.append("CITES")
        if flags:
            bad += 1
        print(f"{name:16}{len(sw):>7}{len(cw):>8}{ratio:>7.2f}{f'{cn}/{sn}':>9}{f'{cf}/{sf}':>8}"
              f"{f'{cm}/{sm}':>9}{f'{len(cc)}/{len(sc)}':>9}{novelty:>7.2f}  {' '.join(flags)}")
        detail.append((name, miss_h, sorted(sc - cc), novel_words, stub))
    print(f"\n{bad} of {len(GROUPS)} chapters flagged.  "
          "(columns: nodes = taxa port/src; figs, math, cites = port/src; novel = share of port "
          "vocabulary absent from the source)")
    if a.verbose:
        for name, miss_h, miss_c, nov, stub in detail:
            if miss_h or miss_c:
                print(f"\n## {name}")
            if miss_h:
                print(f"  headings with no match ({len(miss_h)}): " + "; ".join(miss_h[:12]))
            if miss_c:
                print(f"  cite keys never cited ({len(miss_c)}): " + ", ".join(miss_c[:12]))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
