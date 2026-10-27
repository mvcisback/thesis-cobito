# Concepts and their Representations {#ch:concepts}

> \strong{Knight}: The name of the song is called 'Haddocks' Eyes'!
>
> \strong{Alice}: Oh, that's the name of the song, is it?
>
> \strong{Knight}: No, you don't understand, that's what the name is called.
>
> — Lewis Carroll, Through the Looking Glass, 1871

This thesis lies at the intersection of many sub-disciplines, and as the chapter
quote suggests, these chapters develop a consistent terminology and mathematical
machinery. We begin with a brief introduction to formal languages, concept
classes, and representation classes, laying the groundwork for encoding the set of
behaviors that constitute an agent completing a task. We start with the abstract
formalism of a concept class.

```macros \label{def:notation}
We write $\universe$ for the universe, $\concept$ for a concept, $\ConceptClass$ for
a concept class, $\alphabet$ for an alphabet, $\emptystring$ for the empty string,
$\Nat$ for the naturals, $\concat$ for concatenation, and $\eqdef$ for "defined as".
We write $\Reg$ for the regular languages, $\encode$ and $\size$ for a
representation's encoding and description length, $\EX$ for a set of labeled
examples, and $\identify$ for an identification map.

\def\universe{\mathcal{U}}
\def\concept{\varphi}
\def\ConceptClass{\Phi}
\def\alphabet{\Sigma}
\def\emptystring{\epsilon}
\def\Nat{\mathbb{N}}
\def\concat{\cdot}
\def\eqdef{\stackrel{\text{def}}{=}}
\def\Reg{\mathrm{Reg}}
\def\encode{\text{encode}}
\def\size{\text{size}}
\def\EX{\mathbb{X}}
\def\identify{\mathcal{I}}
```

\taxon{definition}

### Concept class {#def:concept-class}

Let $\universe$ denote an arbitrary set, the \strong{universe}, whose elements
$x \in \universe$ are \strong{atoms}. A \strong{concept} is a set of atoms,
$\concept \subseteq \universe$. A \strong{concept class} $\ConceptClass \subseteq
2^{\universe}$ is a collection of concepts. When clear from context we abuse
notation and write $\concept : \universe \to \{0, 1\}$ for the indicator
$[x \in \concept]$.

\taxon{example}

### Concepts over the naturals {#ex:concepts-nat}

Let $\universe$ be the naturals $\Nat$. The sets $\concept_1 = \{1, 2, 3\}$,
$\concept_2 = \{x \in \Nat \mid x \text{ is even}\}$, and $\concept_3 = \Nat$ are
concepts; $\{\concept_1, \concept_2, \concept_3\}$ is a finite concept class over
$\Nat$, and $\{x^k \mid x \in \Nat\}$ for all $k \in \Nat$ is an infinite one.

## Formal languages and automata {#sec:kKQ7}

We will later care about which \emph{sequences} of states and observations
constitute completing a task. A sequence is formalized as a string.

\taxon{definition}

### String {#def:string}

Let $\alphabet$ be a set of symbols, an \strong{alphabet}. A \strong{string} is a
finite sequence of symbols from $\alphabet$; $|x|$ is its length. The \strong{empty
string} is the unique string of length $0$, written $\emptystring$. The
\strong{concatenation} of strings $x, y$ is $x \concat y$, with $x$ the
\strong{prefix} and $y$ the \strong{suffix}. For a natural number $k$, $x^k$ is $x$
concatenated with itself $k$ times, where $x^0 \eqdef \emptystring$.

Concepts over the universe of strings are called formal languages.\sidenote{For a
fuller introduction to formal languages, see \cite{DBLP:journals/sigact/Sipser96}.}

\taxon{definition}

### Formal language {#def:language}

A \strong{formal language} $L$ is a set of strings over $\alphabet$. The
\strong{concatenation} of languages $L_1$ and $L_2$ is $L_1 \concat L_2 = \{x
\concat y \mid (x, y) \in L_1 \times L_2\}$. For a natural number $k$, $L^k$ is $L$
concatenated with itself $k$ times, with $L^0 \eqdef \{\emptystring\}$. The
\strong{Kleene closure} is $L^* \eqdef \bigcup_{k=0}^{\infty} L^k$. The
\strong{residual language} (Brzozowski derivative) of $L$ by a string $x$,
written $x^{-1}L$, is $\{y \in \alphabet^* \mid x\concat y \in L\}$ — the
suffixes of strings in $L$ that have prefix $x$.

Many well-studied concept classes of formal languages exist, e.g., the
Chomsky hierarchy of regular, context-free, context-sensitive, and
recursively enumerable languages. For this thesis, it is enough to focus on
regular languages.

```node
# \taxon{definition} \label{def:regular}
Given a finite alphabet $\alphabet$, a language $L$ is \strong{regular} iff
one of the following holds:

- $L \subseteq \alphabet$.
- $L = {L_2}^*$, where $L_2$ is regular.
- $L = L_1 \cup L_2$, where $L_1$ and $L_2$ are regular.
- $L = L_1 \concat L_2$, where $L_1$ and $L_2$ are regular.

We write the set of regular languages as $\Reg$.
```

Regular languages have several attractive properties, such as closure under
union, intersection, complement, concatenation, Kleene closure, and string
reversal, and they contain every finite language, e.g., any language with
bounded string length. A language is regular iff it has finitely many
residual languages. Finally, $\Reg$ is exactly the set of languages a
deterministic finite automaton recognizes (below).

````node
# \taxon{definition} \label{def:dfa}
A \strong{Deterministic Finite Automaton} (DFA) is a 5-tuple
$D = \langle Q, \alphabet, \delta, q_0, F\rangle$, where $Q$ is a finite set
of \strong{states}, $\alphabet$ is a finite alphabet, $\delta : Q \times
\alphabet \to Q$ is the \strong{transition function}, $q_0 \in Q$ is the
\strong{initial state}, and $F \subseteq Q$ are the \strong{accepting
states}. The transition function lifts to strings,
$\delta^* : Q \times \alphabet^* \to Q$, by recursively applying $\delta$,

```math \label{eq:delta-star}
\delta^*(q, x) \eqdef \begin{cases}
    q & \text{if } x = \emptystring\\
    \delta(\delta^*(q, y), \sigma) & \text{if } x=y \concat \sigma
\end{cases}.
```

A string $x$ is an \strong{access string} for state $q$ if
$\delta^*(q_0, x) = q$. $D$ is \strong{trimmed} if every state $q\in Q$ has
at least one access string. $D$ \strong{accepts} $x$ if
$\delta^*(q_0, x) \in F$. Write $L[D]$ for the set of strings $D$ accepts
from $q_0$. $D$ \strong{recognizes} $L$ iff $L = L[D]$.
````

```node
# \taxon{remark}
Unless we say otherwise, we assume $D$ is trimmed.
```

In this thesis, we draw DFAs as directed multi-graphs. Nodes are states and
edges are symbols: an edge connects $q$ to $q'$ if $q \neq q'$ and some
symbol $\sigma \in \alphabet$ transitions $q$ to $q'$, i.e.,
$\delta(q, \sigma) = q'$. The initial state is marked "start," and accepting
states carry a concentric circle.

```node
# \taxon{example}
Consider the parity language, $L_{\text{parity}}$, over $\alphabet = \{0, 1\}$,
the strings whose symbols sum to an even number,

$$L_{\text{parity}} = \Big\{x \in \alphabet^* \mid ~\sum_\sigma x \equiv 0\!\!\pmod{2} \Big\}.$$

\ref{fig:min-parity-dfa} and \ref{fig:big-parity-dfa} show two distinct DFAs
that recognize $L_{\text{parity}}$. Because a DFA recognizes it,
$L_{\text{parity}}$ is regular.
```

```figure \label{fig:min-parity-dfa}
\caption{Minimal DFA encoding of the parity language; implicit self-loops are greyed out.}
<img src="imgs/parity.svg" alt="A 2-state DFA recognizing the parity language.">
```

```figure \label{fig:big-parity-dfa}
\caption{DFA encoding of the parity language with a redundant state.}
<img src="imgs/parity2.svg" alt="A 3-state DFA recognizing the parity language, with a redundant state.">
```

## Representation classes {#sec:formal_lang}

The last example shows that several DFAs can represent the same concept. In
general, a concept can be expressed in many ways, some easier to describe
than others.

```node
# \taxon{example}
Consider the concept $\concept = \{1,2,3\}$. One could describe it using a
unary encoding of its elements, e.g., $\{\text{I}, \text{II}, \text{III}\}$;
as the intersection of two other primitive concepts, e.g.,
$\{1,2,3,4,6\} \cap \{0, 1, 2, 3\}$; or by an indicator for $\concept$, e.g.,
$x \mapsto (x > -1 \wedge x < 4)$.
```

```node
# \taxon{example}
Like DFAs, non-deterministic finite automata (NFAs) represent regular
languages as labeled transition systems. They differ in two ways: an NFA
lets a symbol non-deterministically transition to one of several states, so
lifted to strings, its transition function maps a string to a subset of
states; and an NFA accepts a string if any of these non-deterministically
reached states is accepting. This non-determinism lets some regular
languages be stated exponentially more succinctly than any DFA can.
```

We formalize the distinction between a concept and its description with a
representation class, which has two maps: an encoding map, associating
objects with bit-strings, and a concept map, associating objects with a
concept. The difficulty of describing a concept is the minimum length of the
bit-string associated with it.

````node
# \taxon{definition} \label{def:representation-class}
A \strong{representation class} is a set $\RepresentationClass$ equipped with
two maps,

$$\encode : \RepresentationClass \to \{0, 1\}^*\hspace{4em} \text{concept} : \RepresentationClass \to \ConceptClass,$$

where $\encode$ is injective. A representation class is \strong{bijective} if
$\text{concept}$ is a bijection. The size, or \strong{description length}, of
a representation is the length of its encoding,

```math \label{eq:size}
\size : \RepresentationClass\to \Nat \hspace{3em} \size(r) \eqdef |\encode(r)|.
```

Given $\RepresentationClass$, the description length of a concept is
$\min_{r\in\RepresentationClass}\size(r)$.
````

```node
# \taxon{remark}
Because $\encode$ is injective into the countably infinite set $\{0, 1\}^*$,
the representation class must be countably infinite. This does not rule out
the concept class itself being over an uncountably infinite universe — e.g.,
interval concepts with rational bounds are a valid representation class for
intervals over the reals.
```

```node
# \taxon{example}
Consider the concept class $\ConceptClass$ of all finite ordered sequences of
natural numbers, represented as tally marks, e.g., $5 \mapsto \text{IIIII}$. A
sequence of tally marks can be encoded as a sequence of ones delimited by
zeros, where the number of ones is the tally:

$$\encode: (\text{III}, \text{I}, \text{IIIII}) \mapsto 1110100111110,\qquad \text{concept}: (\text{III}, \text{I}, \text{IIIII}) \mapsto (3, 1, 0, 5).$$

For ordered sequences, this representation of tuples of tally marks is
bijective. For unordered sequences (multisets), the representation class has
several representations of the same concept, and so is not bijective.
```

While this distinction may seem pedantic, it matters a great deal when we
discuss a concept's learnability and assign prior probabilities to concepts,
e.g., using Occam's razor to order prior probabilities by size. When clear
from context, we often conflate representations and concept classes,
particularly when $\text{concept}(\bullet)$ is bijective.

### The DFA representation class {#sec:ar5p}

We care chiefly about concept classes that model some variety of formal
language, and in particular regular languages. So we build a representation
class for $\Reg$ based on DFAs. We first pick an arbitrary DFA for each
regular language and relabel its states by a breadth-first traversal from
$q_0$, taking transitions in a fixed order on $\alphabet$. Every state and
symbol is then associated with an integer, and DFAs that are equivalent up to
relabeled states share the same representation. We encode an arbitrary DFA
$D = \langle Q, \alphabet, \delta, q_0, F\rangle$ as follows.

Let $b_Q$ and $b_\alphabet$ be the number of bits needed to encode $|Q|$ and
$|\alphabet|$,\sidenote{Since $Q$ and $\alphabet$ cannot be empty, we need no
bits for that case.} i.e., $b_Q \eqdef \lceil \log_2 |Q| \rceil$ and
$b_\alphabet \eqdef \lceil \log_2 |\alphabet| \rceil$. Define the encoding map

$$\encode(D) \eqdef \encode(Q) \concat \encode(\alphabet) \concat \encode(F)\concat \encode(\delta),$$

where

$$\begin{aligned}
&\encode(Q) \eqdef 1^{b_Q} \concat 0 \concat \encode(|Q| - 1),\\
&\encode(\alphabet) \eqdef 1^{b_\alphabet} \concat 0 \concat \encode(|\alphabet| - 1),\\
&\encode(\delta) \eqdef \prod_{\substack{q, \sigma, q'\\q' \neq \delta(q, \sigma)}}\hspace{-0.7em}\encode(q)\concat\encode(\sigma)\concat\encode(q'),\\
&\encode(F) \eqdef \begin{cases}
    0 \concat \encode(|F| - 1)~\concat~\prod_{q\in F}\encode(q) & \text{if } 2|F| < |Q| + 1\\
    1 \concat \encode(|Q\setminus F| - 1)~\concat~\prod_{q\notin F}\encode(q) & \text{otherwise}
\end{cases},
\end{aligned}$$

and for a natural number $x$, $\encode(x)$ is a standard binary encoding;
states $q\in Q$ and symbols $\sigma \in \alphabet$ are read as integer
indices. The encoding starts by giving the number of bits needed to encode
the states, by a unary encoding delimited by zero, followed by a binary
encoding of the number of states. It gives the number of bits and alphabet
size the same way. The next bit says whether we give the accepting set or
its complement; that set is given by the binary encoding of its size,
followed by the binary encoding of its elements. Finally, we give the binary
encoding of the state/symbol/next-state triples of the non-stuttering
transitions.

Let $\size(D) \eqdef |\encode(D)|$, and let $m$ be the number of labeled
transitions with $q \neq q'$. For the DFA representation class,

$$\size(D) = 3 + 2 b_Q + 2 b_\alphabet + (|F| + 1) b_Q + m ( b_\alphabet + 2\cdot b_Q ).$$

If $\alphabet$ is fixed, and since $D$ being trimmed implies
$|Q| \leq m + 1$, this gives $\size(D) \in O\big(m\log |Q|\big)$.

```node
# \taxon{example}
Under the standard order $0 < 1$, the minimal DFA for the parity language in
\ref{fig:min-parity-dfa}, $D_\text{parity}$, has encoding

$$\encode(D_\text{parity}) = \underbrace{101}_{\encode(Q)}
\concat \underbrace{101}_{\encode(\alphabet)}
\concat \underbrace{001}_{\encode(F)}
\concat~~\underbrace{011110}_{\encode(\delta)}.$$

The non-minimal DFA in \ref{fig:big-parity-dfa}, $D'_\text{parity}$, has
encoding

$$\encode(D'_\text{parity}) = \underbrace{11010}_{\encode(Q)}
\concat \underbrace{101}_{\encode(\alphabet)}
\concat \underbrace{0000}_{\encode(F)}
\concat~~\underbrace{100010001010111010101}_{\encode(\delta)}.$$
```

### The MinDFA representation class {#sec:0sxj}

Within the DFA representation class above, any regular language has
infinitely many DFAs that recognize it. A natural question is whether we can
build a bijective representation class where each language gets a single
"canonical" DFA. Up to state relabeling, each regular language $L$ does have
a unique minimal DFA. To see this, note that (i) each access string of a
state of $D$ maps to a residual language, and (ii) a state's residual
language does not depend on which access string reaches it. So $|Q|$ is at
least the number of residual languages. Second, this gives a "canonical" DFA
construction that respects residual languages: given a minimal DFA $D$,
build a new DFA $D' = \langle Q',\alphabet, \delta, q_0', F\rangle$, where
$Q'$ is the set of residual languages of $L[D]$, $q_0' = L[D]$, and
$F' = \{q' \in Q' \mid \emptystring \in q'\}$. To make $L[D] = L[D']$,
$\delta'$ must respect the residual-language structure, i.e.,
$\delta'(q', \sigma) = \sigma^{-1}q'$. Finally, to show $D'$ is canonical,
note that the bijection $f$ from $q\in Q$ to its residual language respects
transition functions and acceptance: for all $q\in Q$, $q'\in Q'$, and
$\sigma \in \alphabet$,

$$q \in F \iff f(q') \in F' \hspace{3em} \delta(q, \sigma) = f^{-1}\Big(\delta'\big(f(q), \sigma\big)\Big).$$

So $(\delta, F)$ and $(\delta', F')$ agree up to relabeling by $f$.

```node
# \taxon{remark}
The number of residual languages of a language is the "memory" needed to
recognize it. So the size of the canonical DFA for a regular language $L$
gives exactly the minimum memory needed to recognize $L$.
```

## Learning concepts from examples {#sec:m3I7}

This thesis ultimately wants to learn concepts from unlabeled examples. As we
elaborate in the next part, a fruitful way to tackle this is a series of
reductions to learning concepts from labeled examples. To support this
reduction, we review the relevant definitions and approaches for learning
concepts, and DFAs in particular, from labeled examples.

```node
# \taxon{definition} \label{def:labeled-example}
Given a universe $\universe$, a \strong{labeled example} is a tuple
$(x, l) \in \universe \times \{0, 1\}$. A labeled example is
\strong{consistent} with a concept $\spec$ if $l = [x \in \spec]$. A
collection of labeled examples $\EX$ is consistent with a concept $\spec$ if
all its elements are. Similarly, labeled examples are consistent with a
representation $r$ if they are consistent with $\text{concept}(r)$.
```

```node
# \taxon{example}
Let $\EX = \{(0, 0), (1, 1), (01, 1), (10, 1), (11, 0)\}$ be labeled examples
over the universe of bit-strings, $\universe = \{0, 1\}^*$. $\EX$ is
consistent with the parity language and the universal language $\universe$.
$\EX$ is not consistent with the empty language, $\emptyset$, or the
complement of the parity language.
```

Given a set of labeled examples and a representation class, a natural
question asks for the subset of representations consistent with the labeled
examples. An identification map formalizes this.

```node
# \taxon{definition} \label{def:identification-map}
Given a representation class $\RepresentationClass$, an
\strong{identification map} $\identify$ sends a tuple of labeled examples
and a reference representation, $\langle\EX, r\rangle$, to a distribution
over consistent representations in $\RepresentationClass$,

$$\identify : \EX \times \big( \RepresentationClass \cup \{\bot\}\big) \to \Distr(\RepresentationClass \cup \{\bot\}),$$

where $\bot$ is adjoined to the representation class to mark the lack of a
representation.
```

```node
# \taxon{remark}
Because representation classes are usually countably infinite,
identification maps inherit the limits of distributions over natural
numbers. In particular, there is no uniform distribution over a countably
infinite set, so, unless the representation class is finite, $\identify$
necessarily favors some representations over others.
```

````node
# \taxon{remark}
Let $\EX$ be labeled examples. If, for every representation, $\identify$ can
be read as conditioning on sampling a consistent representation,

$$\identify(r'\mid \EX, r) \propto \begin{cases}
    \identify(r'\mid \bot, r)  & \text{if }r \text{ is consistent with } \EX,\\
    0&\text{otherwise},
\end{cases}$$

then $\identify$ can be re-expressed as an exponential bias towards
representations with small \strong{relative description length} given $r$.
Formally, define

```math \label{eq:relative-size}
\size(r'\mid r) \eqdef -\log \big(\identify(r'\mid \bot, r)\big).
```

Then $\identify(r' \mid \EX, r) \propto e^{-\size(r'\mid r)}$. For example,
when we later learn DFAs from demonstrations, we sample a consistent DFA
exponentially weighted by how many bits describe the new DFA given a
reference DFA, i.e., which states, edges, and accepting labels changed.
````

As the previous remark shows, we can build an identification map from an
"exact" learning algorithm that finds concepts consistent with the examples
and weights them by size. Many exact algorithms exist for a wide range of
representation classes, e.g., DFAs, decision trees, half-planes. In this
thesis, we use identification algorithms as a black box. Still, as an
illustration, we sketch the problem of finding DFAs consistent with labeled
examples. Along the way we introduce ideas used later in this thesis, in
particular augmented prefix trees.

### Prefix trees {#sec:aVlw}

When we learn formal languages as DFAs, it is useful to model the set of
labeled examples as a single object that encodes the prefix relations
between strings — a prefix tree.

```node
# \taxon{definition} \label{def:prefix-tree-concepts}
Let $X$ be a finite set of strings and $X'$ its prefix closure. Let
$\preceq$ be the \strong{prefix relation} on $X'$: given strings $x, x'$,
$x \preceq x'$ iff $x' = x \concat y$. A \strong{prefix tree} (also a trie or
digit tree), $T_X$, is a rooted tree with nodes $X'$, whose edges are the
transitive reduction of $\preceq$, i.e., if $x'$ is a descendant of $x$ then
$x' = x \concat y$.
```

An example is in \ref{fig:prefix-tree-example}. Prefix trees are used in
areas ranging from predictive text completion
\cite{DBLP:journals/mscs/ConnellyM95} to bioinformatics
\cite{DBLP:journals/is/Martinez-Prieto16}.

```custom[latexfig] \label{fig:prefix-tree-example}
\caption{Prefix tree for the strings $\{xx, xyz, xxz, xyy, yzz, yyy\}$.}
imgs/prefix_tree_example.pdf_tex
```

A prefix tree $T_X$ for a set of strings $X$ has several useful properties.
The root of the prefix tree is always the empty string $\emptystring$. The
number of leaves is exactly $|X|$. The depth of the prefix tree is the
longest string in $X$, $\max_{x\in X}|x|$. The maximum out-degree of a node
in $T$, its \emph{branching factor}, is at most the number of symbols it
sees, $|\{\sigma \in \alphabet : \exists w \in X ~.~ w = x\concat\sigma
\concat y\}|$. And expanding $\alphabet$ with extra elements does not change
$T_X$.

```node
# \taxon{remark}
If $|\alphabet|$ is much bigger than $X$ and the longest word in $X$, the
size of $T_X$ is much smaller than $\alphabet$. We later use this to
efficiently represent the paths through a workspace when learning task
specifications, where the alphabet models actions and observations and is
typically much larger than the prefix tree of the demonstrations.
```

If two sets have the same prefix closure, they have the same prefix tree.
For example, $X_1 = \{xx, xyz, xxz, xyy, yzz, yyy\}$ and
$X_2 = \{xyz, xxz, xyy, yzz, yyy\}$ have the same prefix tree. To recover the
original (multi-)set of strings $X$, we can augment the prefix tree's nodes,
$X'$, with a \emph{visitation counter},

$$\# : X' \to \Nat \hspace{3em} \# : x \mapsto |\{y \in X\mid y = x\concat z\}|.$$

A prefix $x \in X$ is then detected whenever (i) $x$ is a leaf in $T$, or
(ii) a node's visitation count does not add up to its children's visitation
counts. For $X_1$ and $X_2$, $\langle\#(xx), \#(xxz)\rangle = \langle 3, 2\rangle$
and $\langle 2, 2 \rangle$ respectively; since $xxz$ is the only child of
$xx$ in $T_X$, this recovers that $xx\in X_1$ and $xx \notin X_2$, as
desired.

Finally, associating prefix-tree nodes with a label $\{0, 1, \bot\}$ gives a
representation of a (multi-)set of labeled examples,

$$\text{label} : X' \to \{0, 1, \bot\}\hspace{4em} \EX_T = \Big\{\big(x, \text{label}(x)\big) \mid x \in X', \text{label}(x) \neq \bot\Big\},$$

where $X'$ is the prefix closure of the labeled examples' strings. We call
such a prefix tree an \strong{augmented prefix tree}, written $T_\EX$.

### Learning DFAs from labeled examples {#sec:hJkf}

We now study identifying DFAs from labeled examples. First, note this
problem is fundamentally under-constrained: for any finite set $\EX$ of
labeled examples, infinitely many regular languages are consistent with
$\EX$. So, rather than identify a single DFA, we seek a distribution of
DFAs. To do so, we first characterize the DFAs consistent with a given
example set $\EX$.

````node
# \taxon{definition} \label{def:coloring}
Let $\EX$ be labeled examples and $T_\EX$ its augmented prefix tree. A
$k$-\strong{coloring} of the prefixes $X'$ is a map
$\text{color} : X' \to \{1, \ldots, k\}$ that partitions the nodes (prefixes)
of $T_\EX$, i.e., $X' = \bigcup_{q\in Q}q$ and each $q, q'\in Q$ is disjoint.
Write $q_x$ for the partition of prefix $x\in X'$.

A coloring is consistent with the augmented prefix tree if it respects the
labeling function,

```math \label{eq:coloring-label}
\forall x, x' \in Q~.~ \Big(\text{label}(x) \neq \bot \wedge \text{label}(x') \neq \bot \Big) \implies \text{label}(x) = \text{label}(x'),
```

and the prefix ordering,

```math \label{eq:coloring-prefix}
\forall q \in Q~.~\forall x, x' \in q~.~\forall y\in \alphabet^*~.~ \big(x\concat y, x'\concat y \in X'\big) \implies \big(q_{x\concat y} = q_{x'\concat y}\big).
```

That is, a coloring is consistent if any two same-colored nodes are
indistinguishable given the label and transition constraints the augmented
prefix tree imposes.
````

```node
# \taxon{remark}
We chose the notation $Q$ for the partitioning to highlight that the
coloring partially defines the states of a DFA (below).
```

```custom[latexfig] \label{fig:coloring2}
\caption{Consistent 2-state coloring: $q_1 = \{\emptystring, x, xx, xxz, xyz, yzz, yz\}$, $q_2 = \{y, yy, yyy, xy, xyy\}$.}
imgs/prefix_tree_example_augmented.pdf_tex
```

```custom[latexfig] \label{fig:coloring3}
\caption{Consistent 3-state coloring: $q_1 = \{\emptystring, x, xx\}$, $q_2 =\{xxz, xyz, yzz, yz\}$, $q_3 = \{y, yy, yyy, xy, xyy\}$.}
imgs/prefix_tree_example_augmented_2.pdf_tex
```

```node
# \taxon{example} \label{ex:pt_augmentation}
Consider the labeled examples

$$\EX = \{(yyy, 1), (xyy, 1), (y, 1), (yzz, 0), (xyz, 0), (xxz, 0)\}.$$

\ref{fig:coloring2} and \ref{fig:coloring3} give two consistent colorings for
$\EX$.
```

```node
# \taxon{remark}
Giving each prefix a unique color, $q_x = \{x\}$, gives a trivially
consistent coloring. So, when searching for a single consistent coloring, we
can restrict our attention to $|X'|$-colorings.
```

```node
# \taxon{remark}
Given any consistent $k$-coloring, we can build a $(k+1)$-coloring by
extending the color map's co-domain. The result has "unused" colors.
```

Operationally, a coloring partially defines a DFA
$D = \langle Q,\alphabet, \delta,q_0, F\rangle$: the states $Q$ are the
colors; the transition function is partially defined by the prefix
relation, i.e., if there is a path from $x$ to $x' = x\concat y$ in the
prefix tree, $\delta^*(q_x, y) = q_{x'}$; the initial state is the color of
the empty string, $q_0 = q_\emptystring$; and the accepting states are
bounded above and below by the label constraints,

$$\{x\in X'\mid \text{label}(x) = 1\} \subseteq F \subseteq Q \setminus \{x \in X'\mid \text{label}(x) = 0\}.$$

A general DFA extraction algorithm then works as follows:

1. Select a $k\in \Nat$.
2. Select a $k$-coloring consistent with $T_\EX$. If none exists, return to step 1.
3. Build a DFA by arbitrarily completing the partially defined accepting set and transition function.

```node
# \taxon{example}
Building on \ref{ex:pt_augmentation}, \ref{fig:pt_dfas} shows two DFAs
consistent with the coloring in \ref{fig:coloring2}. These DFAs differ in
how they complete the transition function: the transitions with symbol $x$
after seeing symbol $y$ are left unconstrained by the coloring and the
augmented prefix tree. There are 12 two-state and 2,243 three-state DFAs
consistent with $\EX$.
```

```custom[latexfig] \label{fig:pt_dfas}
\caption{Two consistent DFAs derived from the 2-state coloring $q_1 = \{\emptystring, x, xx, xxz, xyz, yzz, yz\}$, $q_2 = \{y, yy, yyy, xy, xyy\}$.}
\begin{minipage}{0.46\linewidth}\centering\input{imgs/dfa_coloring1.pdf_tex}\end{minipage}\hfill\begin{minipage}{0.46\linewidth}\centering\input{imgs/dfa_coloring2.pdf_tex}\end{minipage}
```

```node
# \taxon{remark}
By the observations above, there is always a $|X'|$-state DFA consistent
with the augmented prefix tree. Likewise, extending a $k$-coloring to a
$(k+1)$-coloring introduces a state no labeled example accesses. Such
extensions are necessary to make the set of DFAs a coloring partially
defines complete. But for canonical (minimized) DFAs, the augmented state
may or may not be equivalent to a visited state, so arbitrarily filling in
the rest of the partial DFA's details can give a DFA with fewer than $k+1$
states.
```

Viewed through coloring, we can derive several algorithms for finding DFAs
consistent with a labeled example set. They are generally characterized by
(i) whether the coloring is built incrementally, e.g., by greedy state
merging \cite{DBLP:conf/icgi/LangPP98}; (ii) whether we want one DFA or
several; and (iii) whether the DFAs found are ordered by description
complexity. We focus on algorithms that enumerate the smallest $k$-state
DFAs, as measured by the size function.

```node
# \taxon{remark}
Deciding whether a DFA is a minimally sized DFA consistent with a set of
labeled examples is NP-hard \cite{DBLP:journals/iandc/Gold78}. So several
reductions to the canonical NP-complete problem, Boolean satisfiability
(SAT), exist \cite{coste1997regular,DBLP:conf/icgi/HeuleV10,DBLP:conf/lata/UlyantsevZS15}.
The high-level approach to the SAT reduction for exact DFA learning used in
this thesis's experiments is: (i) build a SAT query, i.e., a Boolean
predicate $f : \{0, 1\}^n \to \{0, 1\}$ that is true iff a DFA with a given
number of states $m$ exists; (ii) linear-search for the minimum number of
states $m^*$ needed; (iii) build a SAT query true iff a DFA with $m^*$
states and $k$ edges in its multigraph exists; (iv) binary-search for the
minimum number of multigraph edges needed; (v) until satisfied, enumerate
all solutions,\sidenote{Given a SAT query $f$ and a solution $x^*$, build a
new SAT query $f(x) \mapsto f(x) \wedge (x \neq x^*)$, which is either
unsatisfiable or satisfiable only with a new solution. This lets us
enumerate solutions.} increasing $m$ and $k$ as needed. Finally, enumerating
a fixed number of DFAs (with distinct regular languages) lets us build an
identification map, weighting the DFAs by their size relative to another
reference DFA.
```

## Bibliographic notes {#sec:MD9r}

The perspectives on concept and representation classes in this chapter come
from computational learning theory \cite{kearns1994introduction} and, to a
lesser extent, Solomonoff's theory of inductive inference
\cite{DBLP:journals/iandc/Solomonoff64a}. Both literatures directly address
the sobering reality that computers operate on discrete objects with finite
description lengths. This rules out encoding arbitrary real numbers, or
asserting uniform priors over infinite representation classes. This is not
a large problem when representations are indexed by parameters, e.g., linear
rewards, but it becomes fundamental when encoding historical dependencies,
where each bit of memory needs a larger and larger description. The
computational resources learning algorithms use for non-trivial concept
classes are also invariably sensitive to the target concept's description
length in the chosen representation class.

As an illustration, we focused largely on minimized DFAs, a well-studied
representation of regular languages \cite{DBLP:journals/sigact/Sipser96}.
We focus on regular languages because they support temporal and Boolean
composition and are foundational in the Chomsky hierarchy of formal
languages \cite{DBLP:journals/sigact/Sipser96}. DFAs support several
inference algorithms \cite{de2010grammatical}, in both the passive
\cite{DBLP:conf/icgi/HeuleV10} and active \cite{DBLP:journals/iandc/Angluin87}
learning settings. In fact, the notion of a prefix tree in this chapter
comes from passively learning DFAs. Still, the later material tries, as
much as possible, to stay agnostic to the particular representation class.

Finally, this thesis's key distinction from prior work on grammatical
inference \cite{de2010grammatical} is how it treats learning from unlabeled,
potentially noisy demonstrations, where demonstrations differ from examples
because of an underlying dynamics model. As we see in the next chapter, this
notion of demonstration comes from the inverse reinforcement learning
literature \cite{DBLP:conf/icml/NgR00}. There, we see that sometimes only a
few positive demonstrations confidently identify a language — against
conventional wisdom in formal language induction, which says one cannot
identify regular languages from positive examples alone
\cite{DBLP:journals/iandc/Gold67}. The loophole is that we do not seek to
learn the regular language exactly, but a belief distribution over regular
languages that (hopefully) concentrates on the correct language. This goal
mirrors other results on learning from positive examples on simple
distributions \cite{DBLP:journals/ml/Denis01,yang2022one}. Our results go
further still, and do not even require positive labels.
