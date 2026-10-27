# Workspaces and Decision Processes {#ch:dyn-prelim}

> You have brains in your head. You have feet in your shoes. You can steer
> yourself in any direction you choose.
>
> — Dr. Seuss, Oh, the Places You'll Go!, 1990

The previous chapter reviewed machinery for representing concepts and formal
languages. This chapter reviews machinery for predicting the behavior of agents
acting in stochastic environments, starting with a few useful probability
distributions. We assume familiarity with elementary probability theory.

```macros \label{def:dynamics-notation}
We write $\uniform(X)$ for the uniform distribution on $X$, $\Reals$ for the reals,
$\PosReals$ for the non-negative reals, $\LSE$ for log-sum-exp, $\softmax$ for the
soft-argmax, $\Act$ for a set of actions, and $\Distr(S)$ for the distributions
over $S$.

\def\uniform{\operatorname{Uniform}}
\def\Reals{\mathbb{R}}
\def\PosReals{\Reals_{\ge 0}}
\def\LSE{\operatorname*{LSE}}
\def\softmax{\operatorname{softmax}}
\def\Act{A}
\def\act{a}
\def\EnAct{A}
\def\Distr{\textit{Distr}}
```

\taxon{definition}

### Distributions and smooth maxima {#def:distributions}

Let $X$ be a discrete set. The \strong{uniform} distribution on $X$ is $\uniform(X)$,
and the \strong{Dirac} distribution with all mass on $x \in X$ is $\delta_x$. If $X$
carries a map $f : X \to \Reals$, the \strong{log-sum-exp} (smooth max) is

$$\LSE(f) \eqdef \log \sum_{x \in X} e^{f(x)},$$

and the \strong{softmax} is its gradient read as a distribution, $\softmax(f) \eqdef
\nabla \LSE(f)$, with $\softmax(f)(x) \propto e^{f(x)}$.

\taxon{remark}

### Smooth maxima relax the hard ones {#rem:smooth}

The smooth max and soft-argmax are differentiable relaxations of $\max$ and
$\operatorname{arg\,max}$: one verifies $0 \le \LSE(f) - \max_{x \in X} f(x) \le \ln
|X|$, tighter as the gap to the maximum grows, while $\softmax(f)$ interpolates
between the uniform distribution (constant $f$) and the Dirac distribution (a
dominant maximum).

## Markov decision processes {#sec:2fDB}

We model an agent acting in a stochastic domain as a Markov decision process.

\taxon{definition}

### Markov decision process {#def:mdp}

A \strong{probabilistic labeled transition system} (PLTS) is a tuple $M = \langle S,
s_0, \Act, P \rangle$ with a finite set of \strong{states} $S$, an \strong{initial
state} $s_0 \in S$, a finite set of \strong{actions} $\Act$, and a transition
function $P : S \times \Act \to \Distr(S) \cup \{\bot\}$. Writing $P(s' \mid s,
\act)$ for the distribution over next states, a PLTS equipped with a \strong{reward}
$r : S \to \Reals$ is a finite \strong{Markov decision process} (MDP). The
\strong{available actions} at $s$ are $\EnAct(s) \eqdef \{\act \mid P(s, \act) \neq
\bot\}$, e.g., a door opens only when a robot is close enough to it. A state with
no available actions is \strong{terminal}. Finally, we assert the \strong{Luce
choice axiom}: each action $\act \in \Act(s)$ is \strong{distinct}, i.e., no two
actions are interchangeable or redundant at a given state \cite{luce1959individual}.

\taxon{remark}

### Conflating MDPs and PLTS {#rem:conflate-mdp-plts}

When \emph{learning} a history-dependent reward, it is not clear ahead of time
what state augmentations are needed to make the unknown reward state-based.
Unless the distinction matters, this thesis conflates Markov decision processes
with their underlying probabilistic labeled transition systems.

```custom[latexfig] \label{fig:mdp_example}
\caption{Example MDP in the form of a bi-partite graph.}
imgs/mdp.pdf_tex
```

\taxon{example}

### A three-state PLTS {#ex:mdp_example}

A PLTS with three states and two actions is pictured as a directed bi-partite
graph in \ref{fig:mdp_example}. The graph's nodes split into \strong{ego-nodes}
and \strong{dist-nodes}. Ego-nodes, circles with black outlines, are states;
dist-nodes, filled black disks, are state distributions, e.g., $P(\bullet \mid s,
a)$. The outgoing edges of a dist-node carry weights that sum to one. For
example, the PLTS in \ref{fig:mdp_example} has $P(s_0 \mid s_0, a_2) =
\tfrac{9}{10}$, and $s_2$ is its unique terminal state. Given a state reward,
e.g., $r : s_i \mapsto i$, the PLTS is also an MDP.

We are ultimately interested in what behaviors an agent can and does generate in
a workspace. A behavior is formalized as a path through an MDP.

\taxon{definition}

### Paths {#def:path}

Given an MDP $M = \langle S, s_0, \Act, P \rangle$, an $n$-length \strong{path}
$\trc$ is a sequence

```math \label{eq:path}
s_0 \xrightarrow{\act_0} s_1 \xrightarrow{\act_1} \cdots \xrightarrow{\act_{n-1}}
s_n
```

in $(S \times \Act)^n \times S$ where $P(s_{i+1} \mid s_i, \act_i) > 0$ for each
$i$. The length of $\trc$ is $|\trc| \eqdef n + 1$, and $\last(\trc)$ denotes its
last element, $s_n$. A path is \strong{complete} if $\last(\trc)$ is a terminal
state. The set of all paths is $\Path$, and the set of complete paths is
$\CompletePaths$.

\taxon{remark}

### Paths as strings {#rem:paths-as-strings}

A path is conveniently viewed as a string that alternates between states and
actions — the perspective already used to write \ref{eq:path}. This lets a path
inherit string operations such as concatenation and decomposition into
prefix-suffix pairs.

Next we turn to the question of modeling an agent's decisions and control
strategies, captured by the notion of a policy.

\taxon{definition}

### Policies {#def:policy}

A \strong{policy} $\policy : \Path \to \Distr(\Act)$ maps paths to distributions
over enabled actions, i.e., $\{\act \in \Act \mid \policy(\act \mid \trc) > 0\}
\subseteq \EnAct(\last(\trc))$. For a path $\trc$ and policy $\policy$, we write
$\policy(\act \mid \trc)$ for the distribution over actions that $\policy$ induces
given $\trc$.

Running a policy $\policy$ in an MDP induces a Markov chain over paths. More
precisely, the probability of a path, $\Pr(\trc \mid \policy, M)$, is given
recursively by

$$\Pr(\trc \mid \policy, M) = \begin{cases}
1 & \text{if } |\trc| = 1,\\
P(s' \mid s, \act) \cdot \policy(\act \mid \trc') \cdot \Pr(\trc' \mid \policy, M)
  & \text{if } \trc = \trc' \concat s \xrightarrow{\act} s'.
\end{cases}$$

The probability of a prefix-free set of paths $X \subseteq \Path$ is the sum over
the individual path probabilities,

```math \label{eq:prefix-free-prob}
\Pr(X \mid \policy) = \sum_{\trc \in X} \Pr(\trc \mid \policy).
```

We write $\trc \sim (\policy, M)$ for sampling a complete path $\trc$ given
policy $\policy$ and MDP $M$.

\taxon{example}

### Sampling a path from the example PLTS {#ex:mdp_example_prob}

Consider again the MDP in \ref{fig:mdp_example}, and the policy

$$\policy(\act \mid \trc) \propto \begin{cases} 1 & \text{if } \act = a_1,\\
|\trc| - 1 & \text{otherwise}. \end{cases}$$

The complete path $\trc = s_0 \xrightarrow{a_1} s_0 \xrightarrow{a_2} s_0
\xrightarrow{a_1} s_1 \xrightarrow{a_1} s_2$ has probability

$$\left(1 \cdot \frac{1}{5}\right) \cdot \left(\frac{1}{2} \cdot
\frac{9}{10}\right) \cdot \left(\frac{1}{3} \cdot \frac{4}{5}\right) \cdot
\left(1 \cdot 1\right) = \frac{3}{125}.$$

\taxon{remark}

### History-dependent policies {#rem:history-dependent-policies}

For control, it suffices to consider state-based policies $\policy : S \to
\Distr(\Act)$. But for learning from behavior, there is no reason to believe a
demonstrator uses a stationary, state-based policy. In fact, we will see that
bias-minimizing predictions of an agent's behavior — formalized as entropy —
necessarily forecast using history-dependent policies.

## Behavior Prediction and Agent Models {#sec:behavior-prediction}

Next we turn to predicting and explaining the behavior of an agent acting in an
MDP. Traditionally, one models such an agent as using a policy that
(approximately) optimizes the expected sum of rewards\sidenote{To make the
expectation well defined, one often assumes the episode ends with constant
probability.},

```math \label{eq:mdp-goal}
\max_\policy \E\Big[\sum_{t=1}^\infty r(s_t) \mid \policy, M\Big].
```

A path generated by such an agent is a \strong{demonstration}. The inverse
problem — known as inverse reinforcement learning \cite{abbeel2004apprenticeship}
or inverse optimal control \cite{kalman1964linear} — is defined informally below.

\taxon{definition}

### Inverse reinforcement learning {#def:irl}

An \strong{inverse reinforcement learning} (IRL) problem is a tuple $\langle M,
\Xi, R \rangle$, where $M$ is an MDP, $\Xi$ is a multi-set of demonstrations, and
$R$ is a class of reward functions. A solution to an IRL problem is a reward
$r \in R$ that "explains" $\Xi$ given $M$.

In the context of IRL, \ref{eq:mdp-goal} is at once too strong and
under-constrained an assumption. At one extreme, every policy optimizes
\emph{any} constant reward. At the other extreme, a sufficiently expressive
reward class may contain rewards that overfit to the demonstrations — e.g., if
the transitions are deterministic, the membership indicator $[\trc \in \Xi]$
makes the demonstrations (and only the demonstrations) look optimal. Either way,
some other criterion must disambiguate rewards.

Second, when MDPs model physical environments, a policy that optimizes
\ref{eq:mdp-goal} may demand super-human precision, planning, and consistency.
Policies prescribed by \ref{eq:mdp-goal} are thus often ill-suited for reasoning
about human-generated paths — a problem compounded whenever the dynamics model
used for inference differs from the one used by the agent.

Finally, for a given reward there is often more than one optimal policy. For
example, under a constant reward both a uniform distribution over actions and a
deterministic policy are optimal, yet their predictions are very different.
Prediction again needs some other criterion to choose among them.

## Entropy Regularized Planning and Prediction {#sec:entropy-regularized}

A popular, and in practice effective, solution to the ambiguity of IRL is to
appeal to the \strong{principle of maximum causal entropy}. The result is a
unique agent model that is no more biased — formalized as causal entropy — than
is required to match assumed or observed characteristics of the agent, e.g.,
keeping an average of ten feet from a wall. We first review the relevant
definitions from information theory and directed information theory, then
review maximum causal entropy IRL.

\taxon{definition}

### Surprisal, cross entropy, and entropy {#def:entropy}

The \strong{surprisal} (information content) of an event with probability $p$ is
$\log \tfrac{1}{p}$. Let $P$ and $Q$ be distributions over a discrete set $X$.
The \strong{cross entropy} of $P$ under $Q$ is the average surprisal, w.r.t.
$Q$, under $P$,

$$H_P(Q) \eqdef \E_{x \sim P}\Big[\log \frac{1}{Q(x)}\Big] = -\sum_{x \in X} P(x)
\log Q(x),$$

where $0 \log 0 \eqdef 0$. The \strong{entropy} of $P$ is $H(P) \eqdef H_P(P)$.
Entropy extends to a random variable $\RV{X}$ via the distribution over its
outputs, and is written $H(\RV{X})$.

\taxon{remark}

### Entropy is relabeling invariant {#rem:entropy-relabeling}

$H$ is a functional, and is invariant under relabelings (bijective
transformations) of $X$.

\taxon{remark}

### Entropy's logarithmic base {#rem:entropy-base}

Entropy is defined relative to a logarithmic base, with all choices equivalent
up to a multiplicative constant. Common bases are $2$ and $e$, with the
corresponding units being bits and nats, respectively.

When $\log$ is base 2, entropy $H(P)$ is interpreted, via the Source Coding
Theorem \cite{cover2012elements}, as the average number of bits needed to record
values of $X$ drawn from $P$ — informally, the degree of uncertainty in $P$. For
example, if $P$ is uniform then $H(P) = \log |X|$, i.e., (after rounding up)
exactly the number of bits needed to index every element of $X$. If $P$ is
entirely concentrated on one element, $H(P) = 0$: no bits are needed, since the
sampled value is already known.

Likewise, the cross entropy $H_P(Q)$ is the expected number of bits needed to
record values from $X$ drawn from $P$, using an encoding optimized for $Q$. The
excess bits used by $H_P(Q)$ relative to $H(P)$ is known as the
Kullback-Leibler divergence (relative entropy).

\taxon{definition}

### KL-divergence {#def:kl-divergence}

Let $P$ and $Q$ be distributions over a discrete set $X$. The
\strong{KL-divergence} from $Q$ to $P$ is

$$\KL(P \mid\mid Q) \eqdef H_P(Q) - H_P(P) = \E_{x \sim P}\Big[\frac{\log
P(x)}{\log Q(x)}\Big].$$

\taxon{remark}

### KL-divergence is non-negative {#rem:kl-nonneg}

By Gibbs' inequality, $\KL(P \mid\mid Q) \ge 0$, with equality iff $P = Q$. In
terms of encodings: designing for $Q$ and evaluating on $P$ is sub-optimal in
the number of bits used \emph{unless} $P = Q$.

\taxon{remark}

### KL-divergence as the more fundamental measure {#rem:kl-fundamental}

In many ways KL-divergence is more fundamental than entropy. For example, on a
discrete space the entropy $H(P)$ is exactly the KL-divergence from $P$ to the
uniform distribution, $H(P) = \KL(P \mid\mid \uniform)$.

Next we formalize how uncertainty decreases as observations are made, via joint
and conditional entropy.

\taxon{definition}

### Joint and conditional entropy {#def:joint-conditional-entropy}

Let $\RV{X}$ and $\RV{Y}$ be discrete random variables with joint distribution
$P$. The \strong{joint entropy} of $\RV{X}$ and $\RV{Y}$ is $H(\RV{X}, \RV{Y})
\eqdef H(P)$. The \strong{conditional entropy} of $\RV{Y}$ given $\RV{X}$ is

```math \label{eq:conditional_entropy}
H(\RV{X} \mid \RV{Y}) \eqdef H(\RV{X}, \RV{Y}) - H(\RV{Y}) = \E_{(x, y) \sim
(\RV{X}, \RV{Y})}[-\log \Pr(\RV{X} = x \mid \RV{Y} = y)].
```

\taxon{remark}

### A chain rule for joint entropy {#rem:entropy-chain-rule}

Consider a sequence of random variables $\RV{X}_{1:T} \eqdef \RV{X}_1, \ldots,
\RV{X}_T$. Manipulating \ref{eq:conditional_entropy} gives a \strong{chain rule}
for building joint entropies from increasingly constrained conditional
entropies,

```math \label{eq:entropy-chain-rule}
H(\RV{X}_{1:T}) = \sum_{t=1}^{T-1} H(\RV{X}_{t+1} \mid \RV{X}_{1:t}).
```

\taxon{remark}

### Conditioning never increases entropy {#rem:uncertainty-decrease}

Since $\RV{Y} = y$ is itself a random variable, $H(\RV{X} \mid \RV{Y}) =
\E_{y \sim \RV{Y}} H(\RV{X} \mid \RV{Y} = y)$: conditioning by a random variable
is a convex combination of the entropies of the conditional distributions.
Combined with the chain rule, this gives a straightforward way to compute
entropies recursively, and also shows conditional entropy is always
non-negative. Applying Jensen's inequality, $f(\E[\RV{X}]) \le \E[f(\RV{X})]$ for
convex $f$, gives the desirable property that conditioning never increases
entropy: for all random variables $\RV{X}, \RV{Y}, \RV{Z}$,

```math \label{eq:uncertainty-decrease}
H(\RV{X} \mid \RV{Y}) \ge H(\RV{X} \mid \RV{Y}, \RV{Z}) \ge 0.
```

### Causal entropy {#sec:causal-entropy}

When modeling temporally generated sequences of random variables, such as
paths, it helps to introduce causal conditioning. Unlike ordinary entropy,
causal entropy does \emph{not} condition on variables that have not yet been
revealed, e.g., on future events. This makes it well suited for measuring
predictability in sequential decision-making, since an agent cannot observe the
future \cite{mceThesis}.

\taxon{definition}

### Causally conditioned probability and entropy {#def:causal-entropy}

Let $\RV{X}_{1:T}$ and $\RV{Y}_{1:T}$ be sequences of random variables. The
probability of $\RV{X}_{1:T}$ \strong{causally conditioned} on $\RV{Y}_{1:T}$ is

```math
\Pr(\RV{X}_{1:T} \cmid \RV{Y}_{1:T}) \eqdef \prod_{t=1}^T \Pr(\RV{X}_t \mid
\RV{Y}_{1:t}, \RV{X}_{1:t-1}).
```

The \strong{causal entropy} of $\RV{X}_{1:T}$ given $\RV{Y}_{1:T}$ is

```math \label{eq:causal-entropy}
H(\RV{X}_{1:T} \cmid \RV{Y}_{1:T}) \eqdef \sum_{t=1}^T H(\RV{X}_t \mid
\RV{X}_{1:t-1}, \RV{Y}_{1:t}) = \E_{\RV{Y}_{1:T}, \RV{X}_{1:T}}[-\log
\Pr(\RV{Y}_{1:T} \cmid \RV{X}_{1:T})].
```

\taxon{remark}

### Notation for causal conditioning {#rem:cmid-notation}

Causal conditioning is often written $\mid\mid$. We use $\cmid$ instead, to
avoid confusion with relative entropy.

\taxon{remark}

### Causal entropy bounds static entropy {#rem:causal-vs-static}

Conditioning only decreases uncertainty (\ref{eq:uncertainty-decrease}), and
comparing the definition of causal entropy (\ref{eq:causal-entropy}) with the
entropy chain rule (\ref{eq:entropy-chain-rule}) shows causally conditioned
entropy is lower-bounded by statically conditioned entropy,

$$H(\RV{X}_{1:T} \cmid \RV{Y}_{1:T}) \ge H(\RV{X}_{1:T} \mid \RV{Y}_{1:T}) \ge 0.$$

Interpreted in bits, causal entropy is the description complexity of describing
events as they occur; static entropy is the description length with hindsight.
For example, describing a race in real time means describing each
participant's position given only past positions, whereas with knowledge of
future positions one need only describe when the ordering changes — which
constrains the uncertainty of the time between changes.

To study the predictability of an agent's policy, recall that a policy induces a
Markov chain, and thus a distribution over sequences of states and actions.
Given an MDP $M$ and policy $\policy$, write $\RV{A}_{1:i}$ and $\RV{S}_{1:i}$
for the random-variable sequences of actions and states, respectively. The
causal entropy of a policy for $T$-length paths is

```math \label{eq:policy-causal-entropy-T}
H(\RV{A}_{1:T} \cmid \RV{S}_{1:T}) = \sum_{t=1}^T H(\RV{A}_t \mid \RV{S}_{1:t})
= H(\RV{A}_{1:T-1} \cmid \RV{S}_{1:T-1}) + \E_{s_{1:t}}[H(\RV{A}_T \mid
\RV{S}_{1:T} = s_{1:T})],
```

where the equalities follow from the Markov property: transitions depend only on
the current state and action, and the policy depends only on the previous
states. The uncertainty measured by \ref{eq:policy-causal-entropy-T} is bounded,

$$0 \le H(\RV{A}_{1:T} \cmid \RV{S}_{1:T}) \le T \log |\Act|,$$

with the maximum and minimum realized by the uniform and deterministic policies,
respectively.

\taxon{remark}

### A recursive algorithm for causal entropy {#rem:causal-entropy-recursive}

The third equality in \ref{eq:policy-causal-entropy-T} gives a natural recursive
algorithm for computing $H(\RV{A}_{1:T} \cmid \RV{S}_{1:T})$ backwards in time.

\taxon{remark}

### Padding variable-length paths {#rem:causal-entropy-padding}

The causal entropy of a policy extends to variable-length paths by padding
shorter paths with $\bot$ for the action and state. For example, a path of
length 2 pads to a path of length 4 by

$$\Big(s_0 \xrightarrow{\act_0} s_1\Big) \mapsto \Big(s_0 \xrightarrow{\act_0}
s_1 \xrightarrow{\bot} \bot \xrightarrow{\bot} \bot\Big).$$

With this padding, if $i > |\trc|$ then $H(\RV{A}_i \mid \RV{A}_{1:i-1},
\RV{S}_{1:i-1}, \RV{S}_i = \bot) = 0$: padding does not increase the policy's
uncertainty. Computationally, the recursive algorithm can use either the path's
length or completeness as its base case.

\taxon{remark}

### Infinite-horizon causal entropy {#rem:causal-entropy-infinite-horizon}

Unfortunately, the upper bound is tight (realized by uniform policies), so
causal entropy tends to infinity as $T$ does — in general, one cannot define
causal entropy over all complete paths. Fortunately, for many practical
dynamical systems the first three moments (mean, variance, skewness) of the path
length, over all policies, are bounded — e.g., if the episode ends with constant
probability, or if it ends when a battery with constant discharge probability
runs out. Using the padding trick, letting $\RV{T}$ denote path length and
applying Markov's inequality to the third moment,

$$\Pr(\RV{T} \ge T) \le \frac{\E[\RV{T}^3]}{T^3}.$$

Since the upper bound on causal entropy grows only linearly in the horizon, the
contribution of complete paths longer than $\E[\RV{T}]$ attenuates at least
quadratically. In such settings:

1. The infinite-horizon causal entropy — the limit as $T \to \infty$ — is well
   defined and bounded. We call this limit the \strong{causal entropy of the
   policy}.
2. The causal entropy can be approximated arbitrarily well using a sufficiently
   large planning horizon $T$.

### Maximum causal entropy IRL {#sec:max-causal-entropy-irl}

We now return to inverse reinforcement learning. Recall that the IRL problem
asks: given a set of demonstrations, find a reward that "explains" the agent's
behavior, where explaining typically means the agent's behavior is
approximately optimal under the conjectured reward. Recall also that (i) many
undesirable rewards satisfy this property, e.g., $r : s \mapsto 0$, and (ii) the
set of optimal policies can be infinite, with individual policies predicting
very different behavior.

A popular solution to this lack of a unique policy is to appeal to the
\strong{principle of maximum causal entropy} \cite{mce}: forecast using the
policy whose action sequence $A_{1:\tau}$ has the highest causal entropy
conditioned on the state sequence $S_{1:\tau}$ — i.e., the policy that
maximizes $H(A_{1:\tau} \cmid S_{1:\tau})$, subject to a policy feature $\mathbf{f}
: S \to \Reals^n$ constraint $\E[\mathbf{f}(\RV{S})] = f^*$ (e.g., maximize
entropy subject to keeping the same average distance to other vehicles as seen
in the data). Compared to every other distribution, this policy (i) by
definition does not depend on the future, (ii) by definition is consistent with
the observed feature statistics, and (iii) minimizes the worst-case prediction
log-loss, below.

\taxon{corollary}

### Maximum causal entropy minimizes worst-case log-loss {#cor:mce-worst-case}

(Instance of Theorem 5.10 from \cite{mce}.) Let $n$ be a natural number, $f : S
\to \Reals^n$ a feature function, and $P$ a distribution over actions
$\RV{A}_{1:T}$ and states $\RV{S}_{1:T}$. If $P$ maximizes causal entropy
subject to the feature-moment constraint $\E_P[\mathbf{f}(\RV{S})] = f^* \in
\Reals^n$, then it minimizes the worst-case prediction log-loss

$$\sup_{P'} \E_{(\RV{A}_{1:T}, \RV{S}_{1:T}) \sim P'} \log \frac{1}{P(\RV{A}_{1:T}
\cmid \RV{S}_{1:T})},$$

where (1) $P'$ is causal, i.e., $P'(\RV{A}_{1:T}, \RV{S}_{1:T}) =
P'(\RV{A}_{1:T} \cmid \RV{S}_{1:T}) P'(\RV{S}_{1:T} \cmid \RV{A}_{1:T-1})$, and
(2) the feature moments $\E_{P'}[\mathbf{f}(\RV{S})]$ equal $f^*$ when $\RV{S}$
is revealed sequentially from the known, causally conditioned dynamics
distribution $\Pr(\RV{S}_{1:T} \cmid \RV{A}_{1:T})$.

In the language of description complexity and surprisal, the maximum causal
entropy distribution minimizes the worst-case number of bits needed to describe
the agent's behavior. Applied to Occam's-razor arguments, the principle of
maximum causal entropy is a robust proxy for how hard it is to describe an
agent's behavior.

Connecting back to reward-driven agents in MDPs: if $r(s)$ is a linear
combination of features, $r_\rat(s) = \rat \cdot \mathbf{f}(s)$ with $\rat \in
\Reals^n$, the principle of maximum causal entropy prescribes the following
\strong{entropy-regularized} policy \cite{mce},

$$\log \policy_\rat(\act \mid \trc) \eqdef V_\rat(\trc \concat \act) - V_\rat(\trc),$$

where

```math \label{eq:soft_bellman_backup}
V_\rat(\trc) \eqdef \begin{cases}
r_\rat(\last(\trc)) & \text{if } \trc \in \CompletePaths,\\
\LSE_{\act \in \EnAct(\last(\trc))} V_\rat(\trc \concat \act) & \text{if } \trc
  \in \Path \setminus \CompletePaths,\\
r_\rat(s) + \E_{s'}[V_\rat(\trc \concat s') \mid s, \act] & \text{if } \trc = x
  \concat s \concat \act \text{ with } (s, \act) \in S \times \Act,
\end{cases}
```

and $\rat$ is chosen so that \ref{eq:soft_bellman_backup} matches the feature
demonstrations.

\taxon{remark}

### V and Q, conflated {#rem:v-q-conflated}

This exposition of the maximum causal entropy policy is non-standard in that it
is defined over paths. Typically $V$ is split into a state value function $V$
and an action value function $Q$: $V$ corresponds to the first two cases of
\ref{eq:soft_bellman_backup}, and $Q$ to the last. Since the reward is unknown
and history-dependent, it is often useful to refer to the value of an arbitrary
path prefix — so, unless explicitly required, this thesis conflates the two
value functions.

\taxon{remark}

### The soft-Bellman backup {#rem:soft-bellman-backup}

Replacing LSE with max in \ref{eq:soft_bellman_backup} yields the standard
Bellman backup \cite{bellman1957dynamic} used to compute the optimal policy in
tabular reinforcement learning. For this reason, \ref{eq:soft_bellman_backup} is
called the soft-Bellman backup.

\taxon{remark}

### Exponential bias toward high reward {#rem:exponential-bias}

Maximizing causal entropy corresponds to believing the agent is exponentially
biased toward high-reward policies \cite{mce}:

```math \label{eq:policy_dist}
\Pr(\policy_\rat \mid M) \propto \exp\Big(\E_\trc\big[R_\rat(\trc) \mid
\policy_\rat, M\big]\Big).
```

\taxon{remark}

### The rationality coefficient {#rem:rationality-coefficient}

In the special case of scalar state features, $\mathbf{f} : S \to \PosReals$,
the maximum causal entropy policy (\ref{eq:soft_bellman_backup}) becomes
increasingly optimal as $\rat \in \Reals$ increases, since LSE monotonically
approaches max. We call $\rat$ the agent's \strong{rationality coefficient} in
this setting. As revisited when discussing stochastic games (\ref{ch:erci}),
the rationality coefficient casts the smooth Bellman backup as a multi-objective
optimization,

$$J(\policy) = \E[R(\RV{S}_{1:T}) \mid \policy, M] + \rat \cdot H(\RV{A}_{1:T}
\cmid \RV{S}_{1:T}, \policy, M),$$

trading performance for randomness.

## Bibliographic Notes {#sec:dynamics-bib}

This chapter considered predicting the actions of purposeful agents in Markov
decision processes. Learning objectives by observing an expert has a rich
literature dating back to early work on inverse optimal control
\cite{kalman1964linear}, and more recently via inverse reinforcement learning
(IRL) \cite{DBLP:conf/icml/NgR00}. In IRL, an expert demonstrator optimizes an
\emph{unknown} reward by acting in a stochastic environment — a Markov decision
process — and the goal is to find a reward that explains the agent's behavior.
A fruitful approach casts IRL as Bayesian inference, predicting the most
probable reward function \cite{ramachandran2007bayesian}. To make this
inference robust to demonstration and modeling noise, one commonly appeals to
the principle of maximum causal entropy \cite{jaynes1957information,mce}.
Intuitively, this yields a forecasting model no more committed to any given
action than the data requires, formalized as bounding the worst-case expected
description length of future demonstrations. In the case of linear rewards,
there exist several efficient gradient-based algorithms for finding the most
likely objective \cite{mce}; this thesis largely sets those algorithms aside,
since they do not apply to its goal of learning discrete concepts.

Finally, since the description length is worst-case minimal, the principle of
maximum causal entropy gives a succinct encoding of the demonstrations. This
makes it possible to discuss the total description length of both the
objective (drawn from some representation class) and the path. Viewed this way,
the inference problem is a data compression problem
\cite{DBLP:conf/cie/Adriaans07}, in which one first describes which encoding to
use (by describing the objective) and then describes the demonstrations using
that encoding — giving a direct way to discuss the trade-off between how well an
objective explains an agent's behavior and how hard the objective is to
describe.
