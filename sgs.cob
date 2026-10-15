## Prefix-tree perspective {#sec:prefix-tree}

```macros \label{def:prefix-notation}
We write $\prefixtree$ for a prefix tree, $\Nodes$ and $\Edges$ for its nodes and
edges, $\prefix$ for a node (a prefix), $\pival$ for a pivot value, and $\demo$
for a single demonstration.

\def\prefixtree{\mathcal{T}}
\def\Nodes{N}
\def\Edges{E}
\def\prefix{\rho}
\def\pival{\mathbb{V}}
\def\demo{\trc^*}
```

We start with the prefix tree of the demonstrations. The prefix tree is a way to
reason about the paths the agent did \emph{not} take.

```figure \label{fig:prefix-tree}
\caption{A prefix tree with 12 nodes for the paths on the left.}
<img src="imgs/prefix_tree.svg" alt="Two demonstrated paths on the left and their 12-node prefix tree on the right.">
```

\taxon{definition}

### Prefix tree, ego and env nodes, and pivots {#def:prefix-tree}

Let $\Demos$ be a multiset of demonstrations (paths), and let $\prefixtree =
(\Nodes, \Edges)$ be their prefix tree, where $\Nodes$ and $\Edges$ are the
prefixes (nodes) and the edges. A node $\prefix$ is an \strong{ego node} if its
prefix ends in a state, $\last(\prefix) \in S$; otherwise it is an
\strong{environment (env) node}. A path $\trc$ \strong{pivots} at node $\prefix$
if $\prefix$ is the longest prefix of $\trc$ in $\Nodes$. The \strong{pivot
actions} and \strong{pivot states} of $\prefix$ are the available actions and
states that make a path pivot at $\prefix$:

$$A_\prefix \eqdef \{\act \mid \prefix \concat \act \in \Path \setminus \Nodes\},
\qquad S_\prefix \eqdef \{s \mid \prefix \concat s \in \Path \setminus \Nodes\}.$$

\taxon{example}

### Pivots in the prefix tree {#ex:pivots}

Consider the MDP in the prefix-tree figure above, with two demonstrations
$\demo_1$ and $\demo_2$ — a green dashed line and a black solid line. Their prefix
tree is on the right, with an index on each node. For example, $\prefix_1$ is the
root and $\prefix_7$ is a leaf. Node $\prefix_3$ has $A_{\prefix_3} = \{\uparrow,
\downarrow\}$. A path pivots at every node except $\prefix_2$, because both
outcomes — slipping and not slipping — appear in the demonstrations, so
$S_{\prefix_2} = \emptyset$. The grey dotted line is a suffix $y$ for which
$\prefix_7 \concat y$ pivots at $\prefix_7$, so $\prefix_7$ is not a complete
path: $\prefix_7 \notin \CompletePaths$.

Because weighted averaging and log-sum-exp commute, we can aggregate the values
of a set of actions or states. This motivates the \strong{pivot value} of a node
$\prefix$:

$$\pival_{\prefix}^\spec \eqdef \begin{cases}
\LSE_{\act \notin A_{\prefix}} V_\spec(\prefix \concat \act) & \prefix \text{ is ego},\\
\E_s\!\left[V_\spec(\prefix \concat s) \mid \prefix, M, s \notin S_\prefix\right] & \prefix \text{ is env}.
\end{cases}$$

We write $\pival^\spec \in \Reals^{\Nodes}$ for the node-indexed vector of pivot
values of task $\spec$ under the maximum-entropy agent. Pivot values have two
properties. First, they strictly increase as the task's language grows.

\taxon{proposition}

### Pivot values respect subsets {#prop:monotone}

Let $\trc$ be a complete path that pivots at node $i$. If $\spec \subsetneq \psi$
and $\trc \in \psi \setminus \spec$, then $\pival^\spec_i < \pival^\psi_i$.

\emph{Proof.} This follows inductively from the monotonicity of $\E$, $\sum$, and
$\ln$.

Second, by the smooth Bellman backup, the pivot values \strong{entirely
determine} the values $V$ of the prefixes of the demonstrations. Write
$\hat{V}_k(\pival)$ for the \emph{derived} value at node $k$, and $\Pr(i
\rightsquigarrow k \mid \pival)$ for the probability of moving from node $i$ to
node $k$ under the local policy, $e^{\hat{V}_k(\pival) - \hat{V}_i(\pival)}$.

```figure \label{fig:computation-tree}
\caption{The computation tree of the $\hat{V}$ values for each node of the prefix tree, from the smooth Bellman backup and the pivot values $\pival$.}
<img src="imgs/computation_tree.svg" alt="A computation tree deriving node values from pivot values.">
```

\taxon{example}

### Pivot values determine node values {#ex:pivot-determines}

Consider the prefix tree again. Node $3$ has $A(\last(\prefix_3)) = \{\uparrow,
\downarrow, \rightarrow\}$ and $A_{\prefix_3} = \{\uparrow, \downarrow\}$. Suppose
each action has value $1$. Since node $3$ is an ego node,

$$\pival_{\prefix_3} = \ln\!\left(e^{V(\prefix_3 \concat \uparrow)} + e^{V(\prefix_3
\concat \downarrow)}\right) = \ln(2e) = 1 + \ln 2.$$

By definition $V(\prefix_3) = \ln(e^1 + e^1 + e^1) = 1 + \ln 3$, and by
associativity $V(\prefix_3) = \ln(e^1 + e^{\ln(2e)}) = 1 + \ln 3$ as well. Either
way, the probability of going from node $3$ to node $4$ is $\Pr(\prefix_3
\rightsquigarrow \prefix_4 \mid \pival) = e^{1 - (1 + \ln 3)} \cdot e = \tfrac{1}{3}$.

### Benefits of the local perspective {#sec:local-benefits}

Working with prefix trees and pivots has advantages over working with
demonstrations directly. First, pivot values define a local policy, and so a
demonstration likelihood, that is divorced from the dynamics — in particular from
the number of actions and states. The local policy is determined by the pivot
values, and the pivot values are determined by the local policy,\sidenote{This
follows inductively from the strict monotonicity of expectation and log-sum-exp.}
so knowing the local policy is enough to derive the pivot values. For a non-zero
temperature the maximum causal entropy policy gives every action a non-zero
probability, so we can tell whether a node can pivot by summing the probabilities
of its descendants:

$$A_\prefix = \emptyset \iff \sum_{\act \notin A_\prefix} \Pr(\prefix
\rightsquigarrow \prefix \concat \act \mid \pival) = 0.$$

So the planner is free to use a large — even continuous — workspace model. As long
as the local probabilities do not change, the demonstration likelihood does not
change either.

### Independence of pivot values {#sec:grad-independence}

Second, the pivot actions and states at a node say which pivot values we can
change \emph{independently}. Note that task specifications are history-dependent;
that each pivot action or state reaches a subtree disjoint from the others; and
that in an expressive enough class, such as minimal DFAs, we can always build two
tasks $\spec, \spec'$ whose languages differ on a single path. Since pivot values
strictly increase as a language grows (the proposition above), $\pival^\spec$ and
$\pival^{\spec'}$ then differ in a single coordinate.

## Manipulating likelihoods and surprisal {#sec:surprisal}

```macros \label{def:surprisal-notation}
We write $\surprise$ for surprisal and $\size$ for description length.

\def\surprise{h}
\def\size{\operatorname{size}}
```

The question that drives the algorithm is: given the current candidate task,
which counter-factuals still need an explanation? We make it precise in three
steps. We measure how surprising the demonstrations are, in nats, under the pivot
values of the current task. We see how the description length changes as the
pivot values change. And we turn a suggested change in pivot values into a change
in the task.

\taxon{definition}

### Pivot and task surprisal {#def:surprisal}

Let $\prefixtree = (\Nodes, \Edges)$ be a prefix tree of demonstrations $\Demos$.
The \strong{pivot surprisal} is a map $\hat{\surprise} : \Reals^d \to \Reals$,
where $d$ is the number of nodes that can pivot, with

$$\hat{\surprise}(\pival) \eqdef -\sum_{(i,j) \in \Edges} \#_{(i,j)} \cdot \ln
\Pr(i \rightsquigarrow j \mid \pival).$$

The \strong{task surprisal} of a task $\spec$ is the pivot surprisal of
$\pival^\spec$: $\surprise(\spec \mid \Demos) \eqdef \hat{\surprise}(\pival^\spec)$.

\taxon{remark}

### Surprisal is the negative log likelihood {#rem:surprisal-nll}

The task surprisal is the negative log likelihood of the demonstrations,
$\Pr(\Demos \mid \spec, M) = e^{-\surprise(\spec \mid \Demos)}$. We work with
surprisal, not likelihood, for two reasons. The gradient of $\hat{\surprise}$ has
a simple form. And surprisal reads as a description length, so we can treat the
combined description length of the demonstrations and the task as one object: a
size prior on tasks gives $\Pr(\spec \mid \Demos, M) \propto \exp\big(-(\surprise(\spec
\mid \Demos) + \size(\spec))\big)$. We seek a task that is easy to describe and
also explains the demonstrations.

### Pivot surprisal gradients {#sec:surprisal-gradients}

We now ask: how could the pivot values change to make the demonstrations more
likely? For an ego node we might want the observed actions to have a large value
and the pivot value a small one, so the agent has no incentive to pivot. Changing
a pivot value changes the policy non-locally — changing $\pival_9$ in the
computation tree also changes nodes 9, 8, 2, and 1 — but the gradient of
$\hat{\surprise}$ summarizes these upstream effects.

\taxon{proposition}

### The surprisal gradient is set by the local policy {#prop:grad}

Let $p_{xy}(\pival)$ be the probability of starting at node $x$ and pivoting at
$y$,

$$p_{xy}(\pival) \eqdef \Pr(x \rightsquigarrow y \mid \pival) \cdot \Big(1 -
\sum_{(y,z) \in \Edges} \Pr(y \rightsquigarrow z \mid \pival)\Big).$$

Then

$$\frac{\partial \hat{\surprise}}{\partial \pival_k} = \sum_{\substack{(i,j) \in
\Edges \\ i \text{ ego}}} \#_{(i,j)} \cdot \big(p_{ik}(\pival) - p_{jk}(\pival)\big).$$

The proof is mechanical and sits at the end of the chapter. The proposition shows
the gradient is simple to compute from the policy on the prefix tree alone.

### Relation to heuristics {#sec:heuristics}

The gradient captures a few intuitive heuristics for changing $\pival$ to make
the demonstrations more likely. Consider an ego edge $(i, j)$, an action the
agent took. Pivoting at $i$ (that is, $k = i$) gives $p_{jk}(\pival) = 0$, so the
edge contributes positively to the gradient; since we minimize surprisal, this
says to decrease $\pival_k$ and so make the action the agent took look more
valuable by comparison. When $k = j$, $p_{ik} - p_{jk} = \Pr(i \rightsquigarrow j
\mid \pival) \cdot p_{jk} - p_{jk} \le 0$, with equality only when one action is
available, so the edge contributes negatively; this says to increase $\pival_k$,
and so the value of the action used on $(i, j)$. The two readings are:

1. Make the actions taken more optimal, by decreasing the value of the other actions.
2. Make the actions taken less risky, by increasing the value of the possible outcomes.

### Mislabeled counter-factuals {#sec:mislabeled}

We read $-\nabla \hat{\surprise}(\pival^\spec)$ as a prescription for changing the
pivot values to make the demonstrations less surprising. But a class as
expressive as DFAs risks overfitting the demonstrations and ignoring the prior,
so the goal is not to descend $\nabla \hat{\surprise}$ but to identify
counter-factual paths that need an explanation.

If $\frac{\partial \hat{\surprise}}{\partial \pival_\prefix} > 0$ at a pivot
$\prefix$, we can decrease the surprise by decreasing $\pival_\prefix$. By the
monotonicity proposition, one concrete way to decrease $\pival_\prefix$ is to
remove a path from the language of $\spec$. So a large
$\frac{\partial \hat{\surprise}}{\partial \pival_\prefix}$ is evidence of a
counter-factual path $\trc \in \spec$ that pivots at $\prefix$ and needs an
explanation — "the agent did not take the shortcut through the lava because it
avoids lava". A negative gradient suggests a counter-factual path that should be
\emph{added} to $\spec$ — "the agent moved near the ledge because, even if it
slips, $\trc$ still completes the task".

\taxon{remark}

### The toggle criterion {#rem:toggle}

Let $\trc$ be a complete path with pivot $\prefix$ such that $\trc \in \spec \iff
\frac{\partial \hat{\surprise}}{\partial \pival_\prefix} > 0$. If $\trc$ is likely
under $\policy_\spec$, so it has a large effect on $\pival$, and the gradient
$\frac{\partial \hat{\surprise}}{\partial \pival_\prefix}$ is large in absolute
value, then $\spec$ may mislabel $\trc$.

## Specification search {#sec:spec-search}

```macros \label{def:diss-notation}
We write $\EX$ for a set of labeled examples and $\identify$ for the
identification algorithm.

\def\EX{\mathbb{X}}
\def\identify{\mathcal{I}}
```

This section turns the earlier insights into the Demonstration Informed
Specification Search (DISS) algorithm, which systematizes the question: given the
current candidate task, which counter-factuals still need an explanation?

DISS assumes a multiset of expert demonstrations $\Demos$; \emph{black-box}
access to an identification algorithm $\identify$ that maps labeled paths to a
distribution over tasks; and \emph{black-box} access to a planner that estimates
the probability of a path under a candidate task (a later part). DISS cycles
between three components (the DISS cycle, \ref{fig:diss-overview}):

1. \strong{Candidate sampler.} A candidate task $\spec$ is sampled from
   $\identify(\bullet \mid \EX, \spec')$, where $\EX$ is a set of labeled examples
   (initially empty) and $\spec'$ is the task proposed before.
2. \strong{Surprisal guided sampler.} Using the surprisal gradient, the planner
   finds paths the current task may mislabel.
3. \strong{Example buffer.} From the data seen so far, the buffer yields a set of
   positive and negative example paths. It is the buffer that lets DISS backtrack
   and drop labeled paths that do not usefully constrain the identifier.

The candidate sampler is user-provided, so what remains is the surprisal guided
sampler and the example buffer.

\taxon{remark}

### DISS is a guided random walk {#rem:diss-walk}

DISS is a random walk through labeled-example space, guided by the surprisal
gradient of the sampled tasks. Each new labeled example constrains the next task
to address a counter-factual, and this accumulation of corrective constraints
focuses the candidate sampler on ever more probable — lower energy — tasks.

\taxon{remark}

### DISS is representation-agnostic {#rem:diss-repr}

Adapting DISS to a new representation class only changes the identifier. We have
discussed learning DFAs from positive examples; similar algorithms exist for
decision diagrams \cite{DBLP:conf/fmcad/TorfahSCAS21}, linear temporal logic
\cite{DBLP:conf/fmcad/NeiderG18}, and syntactically defined programs
\cite{DBLP:conf/fmcad/AlurBJMRSSSTU13}.

### Surprisal guided sampler {#sec:sgs}

The surprisal guided sampler (\ref{alg:sgs}) builds on the gradient analysis and
the toggle criterion.

```algorithm \label{alg:sgs}
\caption{Surprisal Guided Sampler (SGS)}
\Input $\spec$, $\EX$, $\prefixtree$, $M$, $\beta$
\State compute the planner $\policy_\spec$ from $M$ and $\prefixtree$
\State sample a path $\trc \sim (\policy_\spec, M)$ and a pivot $\prefix \sim \softmax_i \left|\tfrac{1}{\beta} \cdot \frac{\partial \hat{\surprise}}{\partial \pival_i}\right|$ subject to: (i) $\trc$ pivots at $\prefix$; (ii) $\trc \in \spec \iff \frac{\partial \hat{\surprise}}{\partial \pival_\prefix} > 0$; and (iii) some $\spec' \in \RepresentationClass$ is consistent with $\EX \cup \{(\trc, \trc \notin \spec)\}$
\Return $\trc$ \Comment{conjecture a mislabeled path}
```

The sampler takes the current task $\spec$, the labeled examples $\EX$, the
prefix tree $\prefixtree$, the MDP $M$, and a temperature $\beta$. It builds the
maximum causal entropy planner $\policy_\spec$, then forms a joint distribution
over pivots and paths: a $\beta$-annealed softmax over pivots from the surprisal
gradient, and a path distribution from $\policy_\spec$. It samples a pivot
$\prefix$ and path $\trc$ conditioned on $\trc$ pivoting at $\prefix$, the label
of $\trc$ agreeing with the gradient, and $\trc$ keeping some task in the class
consistent. The first two conditions follow the earlier argument that a likely
path with a large pivot value is likely mislabeled; the third keeps attention
inside the representation class — labeling a path through a red tile as positive,
say, is inconsistent with the class.

```figure \label{fig:sgs}
\caption{Overview of the surprisal guided sampler.}
<img src="imgs/sggs.svg" alt="The surprisal guided sampler: plan, score pivots by the surprisal gradient, sample a path.">
```

\taxon{example}

### The gradient flags the detour {#ex:sgs}

Recall the ad-hoc analysis of the gridworld in the running example
(\ref{sec:diss-running-example}). Under the "reach $\yellowTile$, avoid
$\redTile$" hypothesis $\spec$, it is surprising that the agent moves up from
$\blueTile$ rather than following the red dashed suffix: there is a non-trivial
probability to deviate at that prefix, call it $k$. With a 15-step horizon,
$\frac{\partial \hat{\surprise}}{\partial \pival_k}$ is positive and larger in
magnitude than at any other pivot. The monotonicity and gradient propositions
(\ref{prop:monotone}, \ref{prop:grad}) then suggest sampling, under
$\policy_\spec$, a new path $\trc$ that pivots at $k$ and satisfies $\spec$ — the
red dashed suffix fits. Finally, the toggle criterion (\ref{rem:toggle})
prescribes marking $\trc$ as a negative path, which matches the ad-hoc analysis
at the start of the chapter.

\taxon{remark}

### Rejection sampling over pivots {#rem:sgs-reject}

For some pivots no path satisfies all three conditions — a pivot into a fail-sink
of a DFA cannot yield a positive path, say. So we sample a pivot first, then an
extension; a pivot where a condition is impossible has zero mass and drops out.
This rejection sampling repeats until it finds a (pivot, path) pair.

\taxon{remark}

### Only black-box planner access {#rem:sgs-blackbox}

The sampler needs only black-box access to $\policy_\spec$ to assign edge
probabilities $\Pr(i \rightsquigarrow j \mid \pival)$ and to sample suffixes from
a pivot. If the satisfaction probability of an action is also known, Bayes' rule
samples suffixes more efficiently.

### Example buffer and backtracking {#sec:example-buffer}

The last component is the example buffer. It manages the "state" of DISS: which
subset of the labeled examples seen so far is currently constraining the
identifier. This matters because SGS only approximates which counter-factuals to
label, so a greedy accumulation of examples can make a mistake and fall into a
local optimum. To avoid this, the buffer runs a variant of simulated annealing, a
standard technique for heuristic global optimization.

### Simulated annealing {#sec:simulated-annealing}

\emph{Simulated annealing} (SA) \cite{DBLP:conf/wsc/SkiscimG83} is a
probabilistic method that minimizes an energy $U : Z \to \Reals \cup \{\infty\}$.
It needs a \emph{cooling schedule} (a decreasing sequence of temperatures), a
\emph{proposal} distribution $q(z' \mid z)$, and a \emph{reset} schedule that
periodically sets the current state to one of the lowest-energy candidates seen
so far. SA picks an initial $z_0$, picks a temperature $T_t$ from the schedule,
samples a neighbor $z' \sim q(\bullet \mid z_t)$, and accepts it with probability

$$\Pr(\text{accept} \mid z', z_t) = \begin{cases} 1 & dU > 0, \\ \min\{1,
e^{dU / T_t}\} & \text{otherwise}, \end{cases}$$

where $dU \eqdef U(z_t) - U(z')$; a triggered reset instead samples $z_{t+1}$
from the earlier candidates, for example uniformly on the argmin.

For specification inference we take the task posterior to be $\Pr(\spec \mid
\Demos, M) \propto e^{-U(\spec)}$ with energy

$$U(\spec) \eqdef \surprise(\spec \mid \Demos) + \theta \cdot \size(\spec),$$

where $\theta \in \Reals$ sets the weight of the surprisal. By Occam's razor the
task distribution is biased towards simpler tasks, where simplicity is the
description length $\size(\spec)$, and towards tasks that explain $\Demos$, whose
description length is the surprisal.

\taxon{remark}

### What the weight controls {#rem:theta}

$\theta$ plays two roles. It makes $\surprise$ and $\size$ comparable — bits to
nats — and it sets the geometric prior over $\size(\spec)$, with mean
$\tfrac{1}{\theta}$. So set $\tfrac{1}{\theta}$ larger than the description length
of a "large" representation. Below we use $\theta = \tfrac{1}{50}$, telling DISS
the task needs not much more than 50 nats; the ground-truth DFA uses about 40.

### Demonstration informed specification search {#sec:diss-algorithm}

In the language of SA, DISS (\ref{alg:diss}) takes $Z$ to be the tuples of a
labeled-example set and a task, each adjoined with $\bot$, and starts at $z_0 =
(\bot, \bot)$. Its proposal $q(\EX', \spec' \mid \EX, \spec)$ first samples a task
$\spec' \sim \identify(\bullet \mid \EX, \spec)$, runs SGS on $\spec'$ to
conjecture a labeled path $\trc$ giving $\EX'' = \EX \cup \{(\trc, \trc \notin
\spec')\}$, then drops each example with probability $p_{\text{drop}}$ to get
$\EX'$. A reset every $\kappa$ steps resamples $\EX$ from the low-energy tasks and
restarts the task from $\identify(\bullet \mid \EX, \bot)$.

```algorithm \label{alg:diss}
\caption{Demonstration Informed Specification Search (DISS)}
\Input $(\trc_1, \ldots, \trc_m)$, $M$, $\theta$, $N$, $\kappa$, $p_{\text{drop}}$
\State compute $\prefixtree$ from $(\trc_1, \ldots, \trc_m)$ \Comment{build the prefix tree}
\State $\ConceptClass \gets \emptyset$
\For{$t$ in $1, \ldots, N$}
  \If{$t \equiv 0 \pmod \kappa$}
    \State $\EX \sim \argmax_{\psi \in \ConceptClass} U(\psi)$ \Comment{reset periodically}
    \State $(\spec, d\EX) \gets (\bot, \emptyset)$
  \EndIf
  \State $\EX' \gets \operatorname{update}(\EX, d\EX, p_{\text{drop}})$ \Comment{add and drop examples}
  \State $\spec' \sim \identify(\bullet \mid \EX', \spec)$ \Comment{sample a candidate task}
  \State $\ConceptClass \gets \ConceptClass \cup \{\spec'\}$ \Comment{record visited tasks}
  \State $T \gets \text{cooling schedule}(t)$
  \State $dU \gets U(\spec') - U(\spec)$
  \State $\alpha \sim \operatorname{Uniform}(0, 1)$
  \If{$dU < 0$ or $\exp(-dU / T) \le \alpha$}
    \State $(\spec, \EX) \gets (\spec', \EX')$
    \State $d\EX \gets \{\operatorname{SGS}(\spec, T, M)\}$ \Comment{conjecture a labeled example}
  \Else
    \State $d\EX \gets \emptyset$ \Comment{reject the proposal}
  \EndIf
\EndFor
\Return $\ConceptClass$
```

\taxon{remark}

### What annealing buys {#rem:annealing}

Annealing guides the search through labeled-example space for constraints on the
identifier. Three mechanisms keep the examples useful. A proposal that does not
lower the energy is only sometimes accepted. Each step may drop an example, so the
examples that persist are the ones repeatedly re-conjectured when missing. And
resets make global progress after a mistake leads to a local minimum.
