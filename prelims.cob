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

\def\universe{\mathcal{U}}
\def\concept{\varphi}
\def\ConceptClass{\Phi}
\def\alphabet{\Sigma}
\def\emptystring{\epsilon}
\def\Nat{\mathbb{N}}
\def\concat{\cdot}
\def\eqdef{\stackrel{\text{def}}{=}}
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
\strong{Kleene closure} is $L^* \eqdef \bigcup_{k=0}^{\infty} L^k$.
