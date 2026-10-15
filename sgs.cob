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
