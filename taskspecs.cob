# Specifications from Demonstrations {#ch:task_spec}

> Words may show a man's wit, but actions his meaning.
>
> — Benjamin Franklin, scientist and political philosopher, 1706–1790

When we learn from demonstrations, we usually model the demonstrator — a human
expert, say — as acting episodically in a Markov decision process whose goal is
a function of the state. But even when the dynamics are Markovian, many problems
are natural to state in non-Markovian terms.

\taxon{example}

### A non-Markovian gridworld task {#ex:intro}

```figure \label{fig:gridworld}
\caption{The agent enters the water and must dry off before it recharges.}
<img src="imgs/gw8x8_2.svg" alt="An 8-by-8 gridworld with colored tiles and a demonstrated path.">
```

The agent moves in a discrete gridworld. It takes actions to move in the four
cardinal directions, and it senses abstract features of the domain as colors.
The task is to reach any yellow (recharge) tile without touching a red (lava)
tile. But if the agent steps on a blue (water) tile, it must step on a brown
(drying) tile before it goes to a yellow tile. That last constraint needs two
bits of history — one bit for whether the robot is wet, one bit for whether it
recharged while wet — so the task is not Markovian.

Like the example above, many tasks decompose into several sub-tasks. This work
asks how to learn non-Markovian tasks separately and systematically, so that we
can recompose them safely into a larger meta-task.

## A case for Boolean task specifications {#sec:bool-case}

We argue that \emph{non-Markovian Boolean specifications} are a powerful,
flexible, and transferable way to represent a task when we learn from
demonstrations. This stands in contrast to the quantitative scalar reward
functions that usually come with a Markov decision process. A Boolean
specification has three benefits:

1. it expresses tasks with \emph{temporal dependencies};
2. it takes advantage of the \emph{compositionality} in many problems; and
3. it lets us use \emph{formal methods} for planning and verification \cite{seshia-arxiv16}.

A standard scalar reward could also learn this task from demonstrations, but
three problems arise.

First, consider \emph{temporal tasks}. A reward function is usually Markovian,
so a requirement like the one in the gridworld example cannot be stated
directly in the task representation. We could encode time into the state and
reduce the problem to a Markovian reward on new time-dependent dynamics; but in
general this reduction blows the state size up exponentially — the
\emph{curse of history} \cite{pineau2003point}. When we infer a task from
demonstrations, different hypotheses may need different histories, so naively
encoding the whole history quickly becomes intractable.

Second, consider \emph{compositionality}. The gridworld example decomposes into
three sub-tasks. We would like an algorithm that learns each sub-task and
combines them into the whole, rather than one that learns only a single
monolithic task. But for many classes of quantitative reward, combining rewards
is an ad-hoc procedure. People are also notoriously bad at anticipating when a
quantitative reward leads to an unintended consequence \cite{ho_teaching_2015},
which is a serious problem for AI safety \cite{amodei2016concrete} and has led
to work on reward repair \cite{ghosh2018repair}. We could take a linear
combination of the sub-task rewards, but — depending on their relative scales
and on the temporal discount — wildly different behavior results.

Third, consider \emph{brittleness} under small changes to the environment.
Recall the gridworld task. Imagine we learn a reward that encodes "recharge
while you avoid lava" by maximum-entropy inverse reinforcement learning
\cite{ziebart2008maximum} with two binary features: the red lava tile and the
yellow recharge tile.

```figure \label{fig:yr}
\caption{A reward-optimizing agent with discount $\gamma = 0.69$ avoids the lava and recharges.}
<img src="imgs/with-recharge.svg" alt="A gridworld trajectory that reaches a recharge tile and avoids lava.">
```

A reward-optimizing agent, maximizing $\sum_{i=0}^{\infty} \gamma^i r_i(s)$ with
discount $\gamma = 0.69$, takes the path above: it avoids the lava and
eventually recharges.\sidenote{This discount rate is equivalent to an assumption
that at every step the episode ends with probability $1 - 0.69$.}

```figure \label{fig:bug}
\caption{The same reward and discount on a nearly identical world send the agent into the lava.}
<img src="imgs/missing-recharge.svg" alt="A gridworld where the top-left recharge tile is gone and the optimal path enters the lava.">
```

But the \emph{same} reward and discount, on a nearly identical world, send the
agent into the lava. Above, the top-left recharge tile is gone. An acceptable
path is the dashed arrow. Yet the discounted sum of rewards is largest on the
solid arrow — so the agent enters the lava. We could search for a new discount
that avoids this behavior, but such supervision works against the spirit of
learning the task automatically.

We remark that a non-Markovian Boolean reward cannot encode every reward — "run
as fast as you can", say — but such an objective often emerges from a Boolean
task. Consider a race. If at each step there is a non-zero chance of a losing
state, the agent runs forward as fast as it can even for the Boolean task "win
the race".

In summary, a quantitative Markovian reward is a limited task representation
when we learn a task with \emph{temporal dependencies} or
\emph{compositionality} from demonstrations \cite{DBLP:journals/nips/Abel22}.
The need to fine-tune a learned task also undercuts the original purpose of
learning a task representation that is general and invariant to the irrelevant
parts of a task \cite{littman_environment-independent_2017}.

## Contributions {#sec:ts-contributions}

This chapter proposes to represent a task as a Boolean specification, and then
uses the principle of maximum causal entropy to pose learning a specification
from demonstrations as maximum a posteriori (MAP) inference. To support this, we
review a number of folk modeling tricks that show how expressive it is to mix
task specifications and MDPs. We end the chapter with the special case in which
the entropy of the agent's actions, causally conditioned on the revealed states,
equals the entropy of the actions conditioned on all states, past and future.

## Task specifications {#sec:task-specs}

We now adapt the machinery of the previous two chapters to Boolean task
specifications, defined below. We reuse the notation of those chapters and add a
little more.

```macros \label{def:spec-notation}
We write $\RepresentationClass$ for a representation class, $\spec$ for a task
specification, $\Path$ for the paths in an MDP, $\CompletePaths$ for the complete
paths, $\trc$ for a trace, and $\policy$ for a policy.

\def\RepresentationClass{\mathcal{R}}
\def\spec{\varphi}
\def\Path{\operatorname{Paths}}
\def\CompletePaths{\operatorname{Paths}_\$}
\def\trc{\xi}
\def\policy{\pi}
\def\E{\mathbb{E}}
\def\rat{\lambda}
\def\last{\operatorname{last}}
\def\Demos{\xi_1, \ldots, \xi_m}
\def\argmax{\operatorname*{arg\,max}}
```

\taxon{definition}

### Boolean task specification {#def:task-spec}

Let $M$ be an MDP and let $\RepresentationClass$ be a representation class for
sets of complete paths $\CompletePaths$ in $M$ — that is, for all $\spec \in
\RepresentationClass$, $\operatorname{concept}(\spec) \subseteq \CompletePaths$.
A representation $\spec$ from $\RepresentationClass$ is a Boolean \strong{task
specification}.

\taxon{remark}

### Shorthand {#rem:spec-shorthand}

When the context is clear, we shorten "Boolean task specification" to task
specification, specification, or even task.

\taxon{remark}

### Closure under Boolean operations {#rem:spec-closure}

We generally assume task specifications are closed under the Boolean operations.
Given two specifications $\spec, \spec'$, we assume there exist specifications
$(\spec \wedge \spec')$ and $\neg \spec$ with

$$\operatorname{concept}(\neg \spec) = \CompletePaths \setminus
\operatorname{concept}(\spec), \qquad \operatorname{concept}(\spec \wedge \spec')
= \operatorname{concept}(\spec) \cap \operatorname{concept}(\spec').$$

So we can discuss avoiding a task, and doing several tasks at once. Because
conjunction and negation realize any Boolean circuit, we can also represent
doing at least one task in a list, or an assume-guarantee task — for example,
"assuming the other car does not enter the intersection, cross the road".

\taxon{definition}

### Featurized task specification {#def:featurized}

Let $\alphabet$ be an alphabet. A \strong{feature} function (or observation
function) is a prefix-preserving map $f : \Path \to \alphabet^*$: if $\trc \in
\Path$ is a prefix of $\trc' \in \Path$, then $f(\trc)$ is a prefix of
$f(\trc')$. The image of $f$ restricted to $\spec$, written $\widehat{\spec}$, is
an \strong{abstract task specification}.

A task specification $\spec$ (or an abstract one $\widehat{\spec}$) is
\emph{regular} if it is a regular language, and so recognized by a finite-state
machine.

\taxon{example}

### A regular abstract specification {#ex:parity}

Take the parity feature map $f$ that sends each state to its index modulo two.
The parity language — the traces whose feature sum is even,
$\sum_{\sigma \in f(\trc)} \sigma \equiv 0 \pmod 2$ — is an abstract task
specification $\widehat{\spec}$. A two-state DFA recognizes it, so
$\widehat{\spec}$ is regular.

## Task-conditioned behavior prediction {#sec:task-behavior}

The machinery of the dynamics chapter predicts the behavior of an agent that
optimizes a sum of state-based rewards. We can adapt that same machinery to task
specifications. We abuse notation and read a specification as a sparse binary
reward,

$$\spec : \Path \to \{0, 1\}, \qquad \spec(\trc) = [\trc \in \spec] \text{ if }
\trc \text{ is complete, else } 0.$$

If an automaton represents $\spec$, we make this reward Markovian by augmenting
the MDP state with the automaton state.

A task specification corresponds only to complete paths, so it is prefix-free.
Given a policy $\policy$ and an MDP $M$, the probability $\Pr(\trc \in \spec \mid
\policy, M)$ is therefore well defined. This lets us define how competent an
agent is.

\taxon{definition}

### Competent policy {#def:competent}

Given a fixed MDP $M$, a policy $\policy$ is $(p, \spec)$-\strong{competent} if
$\Pr(\trc \in \spec \mid \policy, M) = p$. We call $p$ the \strong{satisfaction
probability} of $\policy$.

With this terminology we can state the inference problem this part studies.

\taxon{problem}

### Task inference from demonstrations {#prob:tifd}

Let $M$, $\RepresentationClass$, and $P$ be a fixed MDP, a task specification
representation class, and a task prior. Let $\policy^*$ be a $(p^*,
\spec^*)$-competent policy, where $p^*$, $\spec^*$, and $\policy^*$ are all
unknown. Given a multiset of i.i.d. demonstrations $\Demos \sim (\policy^*, M)$,
find

$$\spec \in \argmax_{\psi \in \RepresentationClass} \Pr(\Demos \mid \psi, M)
\cdot P(\psi \mid M).$$

By itself this is ill-posed, because $\Pr(\Demos \mid M, \spec)$ is undefined. As
in the dynamics chapter, a popular and effective answer is the principle of
maximum causal entropy.

Since $\policy^*$ is unknown, we use as a proxy the maximum causal entropy policy
that is $(p^*, M)$-competent. The competency is also unknown, so we either treat
it as a hyper-parameter or estimate it empirically, $p^* \approx \frac{1}{m}
\sum_{i=1}^{m} \spec(\trc_i)$. The first is useful with few demonstrations, the
second with many. Either way, a competency estimator and the principle of
maximum causal entropy define a map from a task to a policy, and so to a
likelihood,

```math \label{eq:maxEntPlanner}
\operatorname{maxEntPlanner} : \spec \mapsto \policy_\spec,
```

where $\policy_\spec$ belongs to the entropy-regularized family defined by the
smooth Bellman backup

$$V_\rat(\trc) = \begin{cases}
\rat \cdot \spec(\trc) & \trc \in \CompletePaths, \\
\LSE_{a \in \Act(\last(\trc))} V_\rat(\trc \concat a) & \trc \in \Path \setminus
\CompletePaths, \\
\E_{s'}\!\left[ V_\rat(\trc \concat s') \mid s, a \right] & \trc = x \concat s
\concat a,
\end{cases}$$

with $\ln \policy(a \mid \trc) \eqdef V_\rat(\trc \concat a) - V_\rat(\trc)$. The
satisfaction probability of $\policy_\rat$ is monotonic in $\rat$, so we find a
$\rat$ that matches $p^*$ by a bracketed search such as bisection.\sidenote{The
upper end of the bracket may need to be found first by repeated doubling.}

\taxon{remark}

### The planner as a black box {#rem:planner-blackbox}

Where we can, we use the maximum causal entropy planner as a black box and refer
to the policy $\policy_\spec$ and its value function $V_\spec$. A later part
describes how to implement the planner.
