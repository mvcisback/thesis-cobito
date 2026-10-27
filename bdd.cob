# Stochastic Games as BDDs {#ch:bdd}

> BDDs are somehow special in the "Art of Computer Programming" because they
> weren't anywhere near the scene in 1962. It's really one of the only
> really fundamental data structures that came out in the last 25 years.
>
> — Donald Knuth (Computer Scientist, June 5 2008)

The previous chapter modeled probabilistic systems, and in particular
stochastic games, as abstract circuits. In this chapter, we use Binary
Decision Diagrams (BDDs) \cite{DBLP:journals/tc/Bryant86,DBLP:journals/csur/Bryant92}
to represent the directed acyclic game graphs encoded in these circuits. We
first introduce BDDs, and their relevant properties and operations.
\sidenote{For a more thorough introduction to BDDs, see \cite{knuth2009art}.}

```macros \label{def:bdd-notation}
We write $\true$ for the Boolean constant true, and $\vc$ for a vector of
coin-flip outcomes.

\def\true{\mathit{true}}
\def\vc{\boldsymbol{c}}
```

### Contributions {#sec:C0i1}

With this machinery, we study how BDDs give compressed representations of the
directed acyclic graphs used to build improvisers (\ref{ch:erci}{Improvisation
in Stochastic Games}). This is the final piece in the description of
$\operatorname{maxEntPlanner}$ (\ref{eq:maxEntPlanner}). Further, as in the
previous chapter, model counting computes $q_\spec$, but only for small
values. Here we show how BDDs let us transform model counting into
probabilistic reachability, and so compute $q_\spec$ directly.

Given these BDDs, the natural question is how large they can be. We give
conservative size bounds showing that these BDDs grow at most linearly in the
horizon. This compressed encoding of time-unrolled stochastic games can also be
repeatedly expanded as the time horizon grows, which keeps the dynamics model
compressed throughout planning. Finally, we close with the observation that
BDDs give a natural way to detect and enforce the Luce axiom, as in the
counterexample-guided relaxation of the Luce axiom (\ref{sec:luce-axiom}).
Without further ado!

```node
# \taxon{definition}
Let $n$ be a natural number. A \strong{Binary Decision Diagram} (BDD) over $n$
variables is a finite, rooted, directed acyclic graph $G = (V, E)$ satisfying
four conditions:

1. Nodes and edges are \strong{labeled} with a natural number between $0$ and
   $n+1$, i.e., $\text{label}: V\cup E \to [0\ldots n+1]$.
2. A path $\trc$ in $G$ never visits a label twice, i.e.,
   $v, v'\in \trc \implies \text{label}(v) \neq \text{label}(v')$.
3. Non-sink nodes have exactly two edges, one labeled $0$ and the other
   labeled $1$.
4. A node is a sink iff its label is $0$ or $1$.

A BDD is \strong{ordered} if, along any path $v_1\rightarrow \ldots\rightarrow
v_m$, nodes have strictly decreasing labels, i.e.,
$\text{label}(v_1) > \ldots > \text{label}(v_m)$. A BDD is \strong{reduced} if
it has no isomorphic subgraphs. Unless we say otherwise, we assume BDDs are
ordered and reduced. Finally, let $f$ be an $n$-bit bit-vector predicate. A BDD
\strong{recognizes} $f$ if, for all $x_n, \ldots, x_2 \in \{0, 1\}$,
$f(x_n, \ldots, x_2) = 1$ iff there is a path $v_1\rightarrow \ldots
\rightarrow v_m$ from the root to a sink such that
$\big(\text{label}(v_i) = j > 1\big) \implies \big(\text{label}(v_i, v_{i+1}) = x_j\big)$.
```

```node
# \taxon{example}
The BDDs for the predicates $0: x \mapsto 0$ and $1: x \mapsto 1$ have exactly
one node, labeled $0$ and $1$ respectively. We write these $\mathcal{B}_0$ and
$\mathcal{B}_1$.
```

```custom[latexfig] \label{fig:bdd_example}
\caption{The BDD for the predicate $x_{10} + x_4 + x_3 \equiv 1 \mod{2}$. Nodes are labeled. Edges are solid if labeled $1$ and dotted if labeled $0$.}
imgs/bdd_example.pdf_tex
```

```node
# \taxon{example}
Figure \ref{fig:bdd_example} shows a $9$-variable BDD for the predicate
$x_{10} + x_4 + x_3 \equiv 1 \mod{2}$. Nodes are labeled, and edges labeled $1$
are solid while edges labeled $0$ are dotted. Any path to $1$ crosses an even
number of solid lines.
```

### Properties of BDDs {#sec:9Dr2}

BDDs have useful properties that make them a popular and powerful
representation of Boolean predicates.

### Connection to Automata and Formal Languages {#sec:G4XQ}

In many ways, a BDD's structure mirrors a DFA's. This connection becomes exact
through a related structure, the Quasi-Reduced Binary Decision Diagram (QDD)
\cite{knuth2009art}. A QDD is a BDD except that variables cannot be skipped:
every variable must appear on every path from root to sink. Logically, this
matches traversing edges that consume inputs for decision variables that would
otherwise be skipped. So a QDD is a DFA, where the node labeled $1$ is the only
accepting state. This DFA's language is exactly
$\{x\concat y\in\{0, 1\}^n\concat \{0, 1\}^*\mid f(x) = 1\}$ — hence we say a
BDD \strong{recognizes} $f$. Because the BDD is reduced, each state in this DFA
reaches a unique residual language, so the DFA (QDD) for a given BDD is also
minimal. Most of the properties below follow directly from this connection, so
we often borrow DFA terminology when discussing BDDs, e.g., access strings.

### Operations on BDDs {#sec:yms2}

BDDs support operations such as conjunction, disjunction, exclusive or,
negation, and function composition. Simple graph manipulations implement all
of these, each with polynomial-time complexity (roughly linear or quadratic) in
the size of the BDDs. So, for many Boolean predicates, BDDs give a succinct and
efficient representation for analysis.

### Reduced Ordered BDDs are Canonical {#sec:i60W}

Following from the correspondence with minimal DFAs, reduced ordered BDDs are
canonical: given a predicate $f(x_n, \ldots, x_2)$, there is exactly one BDD
that recognizes $f$. We write this BDD $\mathcal{B}_f$. A useful consequence is
that the Boolean satisfaction query $\exists x~.~f(x) = 1$ is equivalent to
checking whether $\mathcal{B}_f = \mathcal{B}_0$. Since $\mathcal{B}_0$ has
exactly one node, this check takes constant time, once the BDD is built.
Similarly, checking whether predicates $f$ and $g$ are equivalent becomes
checking whether $\mathcal{B}_{f \oplus g} = \mathcal{B}_0$, where $\oplus$ is
exclusive or. Since $\oplus$ is a graph manipulation, equivalence checks are
also simple graph manipulations.

### BDDs Depend on Variable Ordering {#sec:GhsB}

BDD uniqueness holds only given a fixed ordering of $f$'s variables. For
example, let $f$ be the predicate for $(x_2 \wedge x_3) \vee x_4$ and $g$ be
the predicate for $(x_2 \wedge x_4) \vee x_3$. Figure
\ref{fig:bdd_example_not_equiv} shows that $f$ and $g$ have different BDDs; the
size of a BDD depends on the variable ordering.

```custom[latexfig] \label{fig:bdd_example_not_equiv}
\caption{BDDs for $(x_2 \wedge x_3) \vee x_4$ (left) and $(x_2 \wedge x_4) \vee x_3$ (right).}
\begin{minipage}{0.49\linewidth}\centering\input{imgs/bdd_example_f.pdf_tex}\end{minipage}\hfill\begin{minipage}{0.49\linewidth}\centering\input{imgs/bdd_example_g.pdf_tex}\end{minipage}
```

### Model Counting, Probabilistic Reachability, and BDDs {#sec:qD7R}

In the previous chapter, model counting was a central primitive for analyzing
probabilistic circuits. Here we show how to perform model counting of a
predicate $f: \{0, 1\}^n \to \{0, 1\}$ efficiently, by probabilistic
reachability in $\mathcal{B}_f$. This perspective is slightly non-standard, but
it also makes clear that we can compute the random-action competency,
$q_\spec$, directly, using the same algorithm.

To start, read $\mathcal{B}_f$ as an MDP $M$, where actions are selected by
flipping biased coins associated with each input: the states of $M$ are the
nodes of $\mathcal{B}_f$, and the actions of $M$ are $A(s) = \{0, 1\}$ when $s$
is not a sink. The transition probabilities follow: $P(s'\mid s, a)$ is $0$ if
$s$ and $s'$ are not connected, and $b_i \in [0, 1]$ if $\text{label}(s) = i$
and $a=1$. The probability of reaching the state $s^*$ labeled $1$ in $M$ can
then be written as the dynamic programming scheme
\cite{DBLP:conf/tacas/KwiatkowskaNP02}

$$\Pr(\text{reach}(s^*)\mid s) = \begin{cases}
    1 & \text{if }\text{label}(s) = 1\\
    0 & \text{if }\text{label}(s) = 0\\
    b_s s'_1 + (1 - b_s) s'_0 & \text{otherwise},
\end{cases}$$

where $b_s$ is $b_{\text{label}(s)}$ and $s'_{0}, s'_{1}$ are the children of
$s$ reached by $0$ and $1$ respectively. The probability of reaching label $1$
from the root is the satisfaction probability, so if $b_s = \tfrac{1}{2}$ for
all interior states, then

$$\Pr(\text{reach}(s^*)\mid s) = \Prob_{\SampleBV}\;(f(\vx) = 1) = \frac{\#(f)}{2^n}.$$

So, if $b_i = \tfrac{1}{2}$, then $\#(f) = 2^n \Pr(\text{reach}(s^*)\mid s)$, as
desired. Further, if $f$ encoded the unrolled probabilistic circuit for the
task in a workspace MDP, then $\Pr(\text{reach}(s^*)\mid s) = q_\spec$, giving
efficient maximum entropy planning whenever maximum causal entropy coincides
with maximum entropy (\ref{eq:no_feedback}).

### Multi-Terminal BDDs {#sec:4fUd}

So far we have viewed BDDs as modeling Boolean predicates,
$f : \{0, 1\}^n \to \{0, 1\}$. Now suppose we want to model a multi-valued
function, e.g., $g : \{0, 1\}^n \to \{0, 1, \ldots, m \}$. Several variants of
BDDs directly encode such functions, but multi-terminal BDDs can also be
encoded as plain BDDs \cite{DBLP:conf/iccad/SrinivasanKMB90}. We introduce
auxiliary variables $y_1, \ldots, y_m$ and build
$f = h(g(x), y_1, \ldots, y_m)$, where

$$h(z, y_1, \ldots, y_m) = \begin{cases}
    1 & \text{if } z = i \wedge y_i = 1 \wedge \forall j \neq i~.~y_i = 0\\
    0 & \text{otherwise}.
\end{cases}$$

In $\mathcal{B}_h$, the auxiliary variables act as new terminals: if
$g(x) = i$, the final non-terminal node in the BDD must be $y_i$, since the
other output variables have no effect.

```node
# \taxon{remark}
Other encodings of the same idea exist, e.g., using a base-$2$ encoding of
$g(x)$ instead of the $1$-hot encoding above. What matters for us is that the
BDD reached by setting the input variables accesses a sub-BDD that maps
directly to one of the outputs.
```

## Encoding Stochastic Games {#sec:dJ0t}

```custom[latexfig] \label{fig:overview}
\caption{High-level likelihood estimation procedure described in this chapter.}
imgs/overview.pdf_tex
```

As we said at the start of the chapter, our goal is to represent the game
graphs of SGs using BDDs. This section gives the encoding and construction of
such BDDs (Figure \ref{fig:overview} gives an overview). To start, assume our
planning horizon is $\tau$, and that all complete paths have length
$\tau\in \Nat$, using the padding trick from \ref{ch:dyn-prelim}{Workspaces and
Decision Processes}. Recall from the previous chapter that any finite SG can be
written as a sequential circuit $C$ with $n$ inputs and $m$ outputs. Let the
first $q$ inputs of $C$ be coins with biases $b_1, \ldots, b_q$, and the
remaining $n - q$ inputs encode the action. Similarly, let the first output bit
be the assumption monitor's output, and the remaining $m-1$ bits encode the
state $S$. Because the planning horizon is finite, any task restricted to this
horizon must be regular, and so monitorable by a sequential circuit.
\sidenote{A DFA for a regular language converts easily into a sequential
circuit, since both the transition function and the accepting set are lookup
tables.} Unrolling the composition of $C$ and the task monitor circuit for
$\tau$ steps gives a Boolean predicate

$$\widehat{\spec} : \{0, 1\}^{\tau \cdot n} \to \{0, 1\}.$$

### Causal Orderings {#sec:c2RU}

When building the BDD for $\widehat{\spec}$, written $\mathcal{B}_{\widehat{\spec}}$,
we require the order of $\widehat{\spec}$'s inputs to satisfy three conditions
that reflect the decision process we are modeling. First, inputs are
temporally ordered: inputs for earlier time steps have larger labels. Second,
within a time step, the $\pOne$-action bits come before the $\pTwo$-action
bits. Third, within a time step, the action bits come before the coin-flip
decisions. We call such an ordering \strong{causal}, since it respects how
information is revealed to the $\pOne$-agent operating the SG that
$\mathcal{B}_{\widehat{\spec}}$ represents.

### Paths to Bits {#sec:lZn0}

Viewed as automata, these BDDs have causal orderings of the form

$$\big(\{0, 1\}^{n_1}\concat\{0, 1\}^{n_2}\concat\{0, 1\}^q\big)^\tau,$$

i.e., repeatedly process the first $n_1$ $\pOne$-decision variables, then the
$n_2$ $\pTwo$-decision variables, then $q$ coin flips. This gives a map from
paths to bit-vectors,

$$\text{encode} : \CompletePaths \to \big(\{0, 1\}^{n_1}\concat\{0, 1\}^{n_2}\concat\{0, 1\}^q\big)^\tau.$$

So $\mathcal{B}_{\widehat{\spec}}$ compresses an SG where a single action now
corresponds to $n-q$ actions, and a probabilistic transition corresponds to
flipping $q$ coins.

### Enforcing Hard Constraints {#sec:EcWm}

We have now described how to encode an SG and a task specification as a BDD.
Recall that the ERCI problem needs us to handle both a hard constraint $\psi$
and a soft constraint $\spec$. To do this, the pre-processing step on
stochastic game graphs in \ref{ch:erci}{Improvisation in Stochastic Games}
removed every $\pOne$-action where $\pOne$ could not avoid violating the hard
constraint. This requires summarizing which paths violate the hard constraint.
Three terminal BDDs give a direct way to encode whether a path (i) satisfies
$\spec$, (ii) does not satisfy $\spec$, or (iii) violates the assumption $\psi$
monitored by the assumption circuit. So we can post-process the BDD to enforce
satisfying $\psi$, in a single pass starting at terminal (iii), removing any
$\pOne$ decision from which some set of $\pOne$ and coin-flip decisions reaches
(iii).

### Smooth Bellman Backups {#sec:Ttbc}

Before we discuss how big $\mathcal{B}_{\widehat{\spec}}$ is and how to build
it, we must adjust the smooth Bellman backup for two facts: the BDD game graph
skips some decisions, and selected actions and state outcomes are revealed over
several decisions.

Recall that, in the variable ordering, nodes alternate between $\pOne$,
$\pTwo$, and coin-flip decisions. Viewed as a computation graph, the nodes of
the uncompressed stochastic game alternate between taking a log-sum-exp, a min,
and an expectation of child values. To handle the second fact above, note that
these operations are all associative and commutative in their arguments, i.e.,
$\max(\max(x, y), z) = \max(x, \max(y, z))$ and
$\LSE(\LSE(x, y), z) = \LSE(x, \LSE(y, z))$. So the smooth value is well
defined even when split over consecutive decisions.

To handle the first fact, note that, by definition, if a node is skipped in
$\mathcal{B}_{\widehat{\spec}}$, it was inconsequential: the state, or state
distribution, it indexes is the same either way. So the path's reward did not
depend on the decision made at that node. The eliminated $\LSE$, $\min$, and
expectation must therefore have been over a constant value — otherwise the
eliminated sequences would be distinguishable with respect to $\spec$ (or
$\psi$). This gives the identities below, where $\alpha$ is the value of an
eliminated node's children.

```math \label{eq:eliminated_value}
\softmax(\overbrace{\alpha, \ldots, \alpha}^{|A|}) = \log(e^\alpha + \ldots + e^\alpha ) = \ln(|A|) + \alpha,
```

```math \label{eq:2}
\E_x[\alpha] = \sum_{x}p(x)\alpha = \alpha,
```

and

$$\min(\alpha, \ldots, \alpha) = \alpha.$$

A sequence of nodes can also be skipped in $\mathcal{B}_{\widehat{\spec}}$.
Using \ref{eq:eliminated_value}, we can compute the change in value, $\Delta$,
that an eliminated sequence of $k$ $\pOne$-nodes, and any number of $\pTwo$ and
coin-flip nodes, would have contributed:

```math \label{eq:eliminated_value_seq}
\Delta(k, \alpha) = \ln(2^k) + \alpha = k \ln(2) + \alpha.
```

Evaluating this compressed computation graph is linear in
$|\mathcal{B}_{\widehat{\spec}}|$.

```node
# \taxon{remark}
One might wonder whether a skipped decision signals a violation of the Luce
axiom, since the action made no difference. This need not be the case: there
need only be a single task $\spec'$ that distinguishes the decisions. A related
question is whether this correction matters for the results of
\ref{part:learn}{Learning and Teaching}. Running the experiments from
\ref{part:learn}{Learning and Teaching} with and without the correction made no
qualitative difference. So, in practice, it may make more sense to skip the
correction if doing so simplifies the implementation.
```

### Size of Causal BDDs {#sec:a9Fa}

We now return to how big the compressed decision diagram can actually be. We
cite a conservative bound on the size of a BDD, given an encoding of the
corresponding Boolean predicate in the linear model of computation shown in
Figure \ref{fig:linear_model_of_computation} (for more detail, see
\cite{knuth2009art}).

```custom[latexfig] \label{fig:linear_model_of_computation}
\caption{Generic network of Boolean modules for which the size bound below holds.}
imgs/linear_model.pdf_tex
```

Consider an arbitrary Boolean predicate $f: \{0, 1\}^{n} \to \{0, 1\}$ and a
sequential arrangement of $n$ Boolean modules $f_1, f_2, \ldots, f_n$, where
each $f_i$ has shape

$$f_i : \{0, 1\} \times \{0, 1\}^{a_{i-1}} \times \{0, 1\}^{b_i} \to \{0, 1\}^{a_i} \times \{0, 1\}^{b_{i-1}},$$

taking as input $x_i$, the $a_{i-1}$ outputs of its left neighbor, and the
$b_i$ outputs of its right neighbor ($b_0 = 0$, $a_n = 1$). Assume this
arrangement is well defined, e.g., for each assignment to $x_1, \ldots, x_n$
there is a unique way to set each inter-module wire. We say these modules
\strong{compute} $f$ if the final output equals $f(x_1, \ldots, x_n)$.

````node
# \taxon{theorem} \label{thm:bdd_size}
If $f$ can be computed by a linear arrangement of such modules, ordered
$x_1, x_2, \ldots, x_n$, then the size $S \in \Nat$ of $\mathcal{B}_f$ (in the
same order) is upper bounded \cite{bryant1992symbolic} by

```math \label{eq:bdd_bound}
S \leq \sum_{k=1}^n 2^{a_k \cdot \left(2^{b_k} \right)}.
```
````

To apply this bound to our problem, recall that $\mathcal{B}_f$ computes a
Boolean function whose decisions are temporally ordered and alternate between
sequences of agent and environment decisions. Because the traces are bounded,
and all finite sets are regular, there is a finite state machine that monitors
whether the specification is satisfied.

```node
# \taxon{remark}
BDDs ultimately compress the truth table of a Boolean predicate, which is
itself just a string of $2^n$ bits. So, as one might expect, a randomly chosen
predicate — a random sequence of $0$'s and $1$'s — typically has an
intractably large BDD. From \ref{thm:bdd_size}, we can view this as a
consequence of modules needing back edges. Even without the theorem, this
result is inevitable, since the set of small BDDs is much smaller than the
number of all $n$-bit Boolean predicates ($2^{2^n}$). Further, deciding
satisfiability and its negation (tautology detection) take constant time given
a BDD — check whether the BDD has a single node, and that node's label. Since
these are NP-complete and co-NP-complete problems respectively, building the
BDD can take exponential time, even for predicates with a small formula.
```

### Specializing to SGs {#sec:eA5d}

```custom[latexfig] \label{fig:corr_picture}
\caption{Generic module in the linear model of computation for $\mathcal{B}_f$. Backward edges are not required.}
imgs/linear_model2.pdf_tex
```

Because this composed system is causal, no backward wires are needed, i.e.,
$\forall k~.~b_k = 0$. Since the composition of the dynamics and the monitor is
Markovian, the entire system is uniquely described by the monitor/dynamics
state and the agent/environment action (see Figure \ref{fig:corr_picture}).
This description takes $\log_2(2^q|A \times S \times S_\varphi|)$ bits, where
$q$ is the number of coin flips the environment tosses and $S_\varphi$ is the
monitor's state space. So $a_k$ is bounded above by
$\log_2(2^q |A \times S \times S_\varphi|)$. Combined with
\ref{eq:bdd_bound}, this gives the following bound on the size of
$\mathcal{B}_f$.

```node
# \taxon{corollary} \label{corr:bdd_size}
Let $M = (S, s_0, A, P)$ be a stochastic game whose probabilistic transitions
can be approximated using $q$ coin flips, and let $\varphi$ be a specification
defined for horizon $\tau$ and monitored by a finite automaton with states
$S_\varphi$. The corresponding BDD, $\mathcal{B}_{\widehat{\spec}}$, has size
bounded by

$$|\mathcal{B}_{\widehat{\spec}}| \leq \overbrace{\tau \cdot \big( \log(|A|) + q \big)}^{\text{\# inputs}} \cdot \overbrace{\big( 2^q| A \times S \times S_\varphi| \big)}^{\text{bound on } 2^{a_k}}.$$
```

This argument shows that, as the episode length grows, $|\mathcal{B}_{\widehat{\spec}}|$
grows linearly in the horizon and states, and quasi-linearly in the
agent/environment actions.

```node
# \taxon{remark}
This bound holds even for the minimal representation of the composed
dynamics/monitor, even when that representation is unknown in advance. For
example, if the property is $\true$, the BDD needs only one state, so
$|\mathcal{B}_{\widehat{\spec}}| = 1$, independent of the horizon or the
dynamics — so the bound above, which is always linear in $\tau$, is often very
conservative. In general, the size of the BDD depends on the particular
symmetries it compresses.
```

```node
# \taxon{remark}
With hindsight, \ref{corr:bdd_size} is not too surprising. If the monitor is
known, we could compose the dynamics MDP with the monitor explicitly, giving an
MDP with at most $|S \times S_\varphi|$ states. Including the time step in the
state, we could run the soft Bellman backup directly on this automaton. In this
composed automaton, we would need to record each (action, state) pair, so we
would expect $O(|S \times S_\varphi\times A|)$ space. In practice, this
explicit representation is much bigger than $\mathcal{B}_{\widehat{\spec}}$,
because BDDs can skip over time steps and automatically compress symmetries.
```

```node
# \taxon{remark}
In the worst case, the monitor could be the unrolled decision tree, which has
exponentially many states. In practice, we expect the composition of the
dynamics and the monitor to be much smaller.
```

### Constructing Causal BDDs {#sec:construct}

One of the biggest benefits of representing a Boolean function as a BDD is
that we can build BDDs from Boolean combinations of other BDDs. Given two BDDs
with $n$ and $m$ nodes respectively, it is well known that the conjunction or
disjunction of the BDDs has at most $n\cdot m$ nodes. So, in practice, if the
combined BDDs stay relatively small, Boolean combinations stay efficient to
compute, and we never build the full binary decision tree. BDDs also support
function composition: given a predicate $f(x_1, \ldots, x_n)$ and $n$
predicates $g_i(y_1, \ldots, y_k)$, we can compute

$$f\bigg(g_1(y_1, \ldots, y_k), \ldots, g_n(y_1, \ldots, y_k)\bigg)$$

in time \cite{knuth2009art}

$$O(n\cdot |\mathcal{B}_f|^2\cdot \max_i{|\mathcal{B}_{g_i}|}),$$

where $\mathcal{B}_f$ is the BDD for $f$ and $\mathcal{B}_{g_i}$ are the BDDs
for $g_i$. Now suppose $\hat{\delta}_1, \ldots, \hat{\delta}_{\log(|S|)}$ are
Boolean predicates such that

$$\hat{\delta}(\vs, \va, \vc) = (\hat{\delta}_1(\vs, \va, \vc), \ldots, \hat{\delta}_{\log(|S|)}(\vs, \va, \vc)).$$

\ref{thm:bdd_size} and an argument like the one for \ref{corr:bdd_size} show
that building $\mathcal{B}_{\widehat{\f}}$ by repeated composition takes time
bounded by a low-degree polynomial in $|A \times S\times S_\varphi|$ and the
horizon. The space complexity before and after composition is bounded as in
\ref{corr:bdd_size}.

### Evaluating Demonstrations {#sec:demo}

We now return to evaluating the likelihood of a concrete demonstration in our
compressed BDD. The key problem is that the BDD evaluates only binary
sequences of actions and coin flips, while demonstrations are sequences of
action/state pairs. So we need to algorithmically perform the transformation

$$s_0\concat \va_0\concat \vs_1\concat \ldots \concat \va_{n}\concat \vs_{n+1} \mapsto \va_1\concat \vc_1\concat \ldots\concat \va_n \concat \vc_n.$$

Given the random bit model assumption, we can rewrite this transformation as a
series of Boolean satisfiability problems,

```math \label{eq:find_coins}
\exists~ \vc_i~.~\hat{\delta}(\vs_i, \va_i, \vc_i) = \vs_{i+1}.
```

These problems look intimidating, but in practice they are quite simple for
modern SAT solvers, particularly when the number of coin flips is small.
Further, many systems are translation invariant, so the results of a single
query (\ref{eq:find_coins}) can be reused on other queries, e.g., in our
gridworld example, slipping can always be detected by checking whether the
agent moved in the direction it intended. In general, if $q$ coin flips are
used, encoding all $m$ demonstrations takes at most $O(m \cdot\tau\cdot 2^q)$
in the worst case.

### Luce Axiom Relaxation with BDDs {#sec:dneI}

We close this section with a short discussion of realizing the Luce axiom
relaxation using BDDs. The key observation is that if two actions, or states,
are equivalent, they must access the same nodes in a BDD. So, when the maximum
entropy planner ($\operatorname{maxEntPlanner}$, \ref{eq:maxEntPlanner}) is
represented as a BDD, two actions are distinguished exactly when they visit
different nodes of the BDD. This has the slight advantage of being independent
of the particular rationality coefficient used for planning.

## Bibliographic Notes {#sec:TWCQ}

Binary Decision Diagrams were a key tool in the early days of model checking
\cite{DBLP:books/daglib/0007403-2}, and are now used frequently in symbolic
value iteration for Markov Decision Processes \cite{hoey1999spudd} and
reachability analysis for probabilistic systems \cite{KNP11}. The literature
has largely relied on Multi-Terminal BDDs to encode the transition
probabilities for a \strong{single} time step. In contrast, this work
introduces a two-terminal (or three-terminal) encoding based on the finite
unrolling of a probabilistic circuit. The key difference is a focus on
symbolically representing paths rather than the set of reachable states.
Historically, the model checking community took the latter perspective,
presumably because it is a simple extension of non-deterministic state
reachability. The key difference from non-deterministic model checking is that
a state must be associated with the probability of reaching it: representing
all of these probabilities effectively shatters symmetries, and so reduces the
efficacy of a state-based perspective, compared to the non-deterministic
setting.

So, in many settings, despite being a much larger set, the factorized
representation of the set of paths is often more compact. For example, after
appearing in \cite{DBLP:conf/cav/Vazquez-Chanlatte20} (and independently in
\cite{DBLP:journals/pacmpl/HoltzenBM20}), this encoding was later used to
perform finite-horizon model checking on Markov chains, giving noticeable
improvements over state-of-the-art model checkers on standard benchmarks
\cite{DBLP:conf/cav/HoltzenJVMSB20}.

Finally, many of this chapter's results adapt easily to the many variants of
Binary Decision Diagrams, e.g., Zero-Suppressed Decision Diagrams
\cite{mishchenko2001introduction}, which use different rules to compress the
truth table of a Boolean predicate. For an overview of these variants, see
\cite{DBLP:books/siam/Wegener00}.
