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

### Maximum entropy planners {#sec:max-ent-planners}

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

We postpone further discussion of implementing $\operatorname{maxEntPlanner}$
until \ref{part:control}{Prediction and Control}.

### Solution sketch {#sec:AjRt}

With the maximum causal entropy policy $\policy_\spec$ in hand, we can sketch
our high-level strategy for learning tasks from demonstrations:

1. Select a candidate task $\spec$.
2. Compute the prior probability $\Pr(\spec\mid M)$.
3. Compute the likelihood of the demonstrations given the task,
   $\Pr(\Demos\mid \spec, M)$.
4. Score tasks by their posterior probability.
5. Return the maximum a posteriori task.

What remains is to find a way to select candidates with increasing posterior
probability. Three features make efficient inference with this scheme
difficult: the countably infinite number of tasks under consideration; not
knowing in advance what memory the task needs; and the lack of gradients to
guide the search for explanatory tasks. We postpone addressing these problems
until \ref{ch:DISS}{Finding Explanatory Specifications}. For the rest of this
chapter, we instead address the choice of binary co-domain for $\spec$, some
useful modeling tricks that make task specifications more expressive, and
simplifications for the special case when maximum causal entropy coincides
with maximum entropy.

### Choice of binary co-domain {#sec:binco}

One might wonder how sensitive this formulation is to changing the co-domain
of $\spec$ from $\{0, 1\}$ to any other pair of real values, i.e.,
$\spec': \Path \to \{a, b\}$. Subject to mild technical assumptions, almost any
two real values work as $\spec$'s co-domain: unless $a$ and $b$ are both zero,
the expected satisfaction probability $p$ is in one-to-one correspondence with
the expected value of $\spec'$,

$$\E[\spec'] = a\cdot p + b\cdot (1 - p).$$

So, if a policy is feature matching for $\spec$, it is feature matching for
$\spec'$, and vice versa — the space of consistent policies is invariant under
such transformations. Because the space of policies does not change, the
maximum causal entropy policies do not change either. In practice, we prefer
$\{0, 1\}$ as the co-domain for $\spec$, since it simplifies many
calculations.

## Task specification modeling tricks {#sec:tricks}

At first, restricting our attention to task specifications, which can only
take binary values, may seem limiting. But the ability to explicitly model
history, e.g., in DFA states, together with the probabilistic nature of the
underlying MDPs, lets a number of \emph{quantitative} properties emerge.
These include temporal discounting, a preference to keep distance from
obstacles, and minimizing violations of a specification. So task
specifications give a rich modeling formalism that inherits many of the
strengths, and problems, of the Markovian reward setting.

### Discount rates and shortest paths {#sec:discount}

In many settings, it is natural to assume agents are biased towards performing
a task efficiently, e.g., taking the shortest path to a goal. A common way to
encode this preference assumes the agent optimizes a discounted sum of
rewards,

```math \label{eq:discount_rewards}
\E_{\trc}\left[\sum_{s_k \in \trc} \gamma^k \cdot r(s_k)\mid \policy, M\right],
```

where $\gamma \in [0, 1)$. We often turn this discounted sum into a
non-discounted objective, by observing that \ref{eq:discount_rewards} is
equivalent to assuming a special terminal state $\$$ that receives no reward,
$r(\$) = 0$, and that taking an action from any non-terminal state transitions
to $\$$ with probability $1-\gamma$. So, at every time step, the expected
future reward attenuates by $\gamma$, as desired.

The standard reading is that the agent operates in an MDP where the episode
may end with probability $1 -\gamma$ at any time. The agent then prefers to
finish its task as quickly as possible, giving an emergent preference for
shorter paths. So planning with a discounted reward is the same as planning
under the assumption that path lengths follow a geometric distribution with
mean $\tfrac{1}{\gamma}$.

### Batteries {#sec:nZxY}

There are many settings where we want some form of temporal discounting, but
the path-length distribution is not geometric. One example is a robot that
operates with a stochastically depleting battery
\cite{DBLP:conf/cyphy/HermannsKN15}. If the sink $\$$ is reached when the
battery level hits $0$, and the battery level decreases or stays the same with
constant probability,

$$\Pr(\text{battery\_level}(s') = k'\mid \text{battery\_level}(s) = k) = \begin{cases}
    1 & \text{if } k = k' = 0,\\
    \gamma & \text{if } k = k'\neq 0,\\
    1 - \gamma  & \text{if } 0 \leq k - k' \leq 1,\\
    0 & \text{otherwise,}
\end{cases}$$

then the path lengths follow a negative binomial distribution. The geometric
distribution above is a special case, when the initial battery level is $1$.
For larger battery levels, the episode's probability of ending right after the
current action is $0$, which lets the agent plan more optimistically.

```node
# \taxon{remark}
Assuming the initial battery level is $1$ has the benefit that the internal
battery state need not be observed. For larger battery levels, this
necessarily assumes more, or requires estimating the battery level from other
observations, e.g., whether the agent is taking a short but risky path to the
goal, versus a long but safe one.
```

### Slipping and obstacle padding {#sec:aET8}

The last two modeling tricks changed how an agent accounts for time when
planning. For variety, the next trick changes how an agent accounts for the
distance between itself and obstacles or goals. There is often a modeling gap
between the workspace, the agent's model of the workspace, and the model used
to predict the agent's behavior — a common example is distances between
objects and transition probabilities. Such disconnects can make an agent just
barely miss an obstacle (or a goal) in one model, but not in the others, and
temporal discounting makes this worse, since it prefers shorter paths.

```custom[latexfig] \label{fig:model_mismatch1}
\caption{Optimal path in agent model.}
imgs/model_mismatch.pdf_tex
```

```custom[latexfig] \label{fig:model_mismatch2}
\caption{Model mismatch leads to task failure.}
imgs/model_mismatch2.pdf_tex
```

```node
# \taxon{example} \label{ex:reach_avoid}
Consider the agent operating in the workspace shown in Figure
\ref{fig:model_mismatch1}. The agent attempts the task "visit the circular
region and then the star region, while avoiding the rectangular regions."
Under temporal discounting, the agent may try the shortest path, which barely
avoids the red region and skims the goal regions. But the true workspace has
slightly different obstacle distances, so the agent's plan would miss the
targets and enter the rectangular region.
```

The classic, conservative fix is to "bloat" each obstacle (and shrink each
goal) by some margin, and plan in the new model. This works for the example
above, and may even be a good idea for safe control, but for inference it
assigns very little probability mass to the original optimal path, which
gives an undesirably biased prediction of the agent's behavior. Entropy
regularized planning papers over some of this, but the structural bias
remains. For example, if the goal is reachable only through a narrow
corridor, bloating may remove that corridor, giving a trivially false
specification.

Instead, we can encourage the agent to keep its distance from an obstacle by
adding a probability of slipping. Rather than bloating each obstacle, we
induce a distribution over the location a given action may lead to. The
result is an agent that acts as if obstacles are padded, but is still willing
to risk a narrow corridor if no other option is available.

### Stochastic observations {#sec:o0UD}

Modeling slipping is useful for a preference to keep distance from obstacles,
but it does not address an agent's incentive to skim a goal region — the paths
are still not robust to uncertainty in the goal regions. A lightweight
trick\sidenote{The "heavyweight" alternative moves to partially observed
Markov decision processes, which, while expressive, are in general
intractable, or even undecidable.} to model this uncertainty makes the
observation map stochastic,

$$f : \Path \to \Distr(\alphabet^*),$$

where $\alphabet$ marks whether the agent left or entered a
region, the probability of observing a change grows as the agent nears the
center of the obstacle, and it shrinks given the previous observation.

```custom[latexfig] \label{fig:model_mismatch3}
\caption{Optimal path using noisy observations.}
imgs/model_mismatch3.pdf_tex
```

```custom[latexfig] \label{fig:model_mismatch4}
\caption{Path robustly performs reach-avoid.}
imgs/model_mismatch4.pdf_tex
```

```node
# \taxon{example}
Consider the reach-avoid task from \ref{ex:reach_avoid}, but with a noisy
observation function. Here the probability of observing an enter-region token
is weighted by the relative intensities in Figure \ref{fig:model_mismatch3}.
An optimal path keeps its distance from the rectangular obstacles and still
approaches the centers of the goal regions.
```

```node
# \taxon{remark}
Modeling the entering and leaving of a region stochastically, as above, does
not actually need a stochastic observation function. Augmenting the MDP state
with the previous observation, and whether it belongs to the region, is
enough to build an equivalent MDP with a deterministic observation. This is
what makes the approach tractable, compared to the general partially
observable MDP setting.
```

### Minimizing violations and redemption {#sec:ySaR}

Stochastic observations, as above, also answer the question of how to model a
goal of minimizing "violations" of a given specification. Consider again the
sequential reach-avoid task from \ref{ex:reach_avoid}. Suppose we observe the
agent's path, but not the observations it received. For example, say the
agent very briefly enters the rectangular avoid region, then continues to the
two goals. Since the task is \emph{unsatisfiable} after entering the
rectangular region, we must conclude that the agent did not observe entering
it. So, after marginalizing over the possible outcomes, the agent's behavior
is still probable given the task specification — the agent model that results
minimizes "violations" of the specification.

```node
# \taxon{remark}
Modeling the reach-avoid task as a DFA, an alternative trick turns the DFA
into an MDP: when the token to avoid is seen, there is some probability that
the new transition system does not transition to the failing sink state.
This is a useful mental model, but for simplicity, we avoid it in this thesis
and assume the stochastic observations are built into the underlying MDP.
```

## Maximum entropy special case {#sec:maxEntcase}

```macros \label{def:maxentcase-notation}
We write $\KL$ for the Kullback-Leibler divergence, and $\appropto$ for
"approximately proportional to".

\def\KL{D_{\mathrm{KL}}}
\def\appropto{\mathrel{\stackrel{\approx}{\propto}}}
```

In this section, we study the special case when maximum causal entropy
coincides with maximum entropy, i.e.,

```math \label{eq:no_feedback}
H( \RV{A}_{1:T} \cmid \RV{S}_{1:T} ) \approx H( \RV{A}_{1:T} \mid \RV{S}_{1:T} ).
```

This happens whenever the agent's policy does not depend on the revealed state
outcome, e.g., in deterministic systems, where the action pre-determines the
revealed state.

To start, let $M = \langle S, s_0, \Act, P \rangle$ be a fixed MDP where
applying a fixed action sequence yields the same state sequence with high
probability. In $M$, causally conditioning on a state sequence is then
approximately the same as static conditioning (\ref{eq:no_feedback}), so
action sequences effectively determine their path, and so act as policies.

Recall that maximizing causal entropy subject to the expected reward
corresponds to believing the agent is exponentially biased towards high
reward. Substituting the satisfaction probability for expected reward, and
paths for policies (since the dynamics are effectively deterministic), gives

```math \label{eq:path_dist}
\Prob(\trc\mid M, \spec, \rat) \approx \frac{e^{\rat \cdot \spec (\trc)}}{Z_{\spec}},
```

where $Z_{\spec}$ is a normalizing constant and $\rat$ is again tuned to match
the observed competency $p^*$. Perhaps surprisingly, under
\ref{eq:path_dist}, the Boolean nature of $\spec$ forces a simple form for the
path likelihoods.

````node
# \taxon{proposition} \label{prop:ratio}
Let $p_\spec$ be the competency of $\policy_\spec$, and let $q_\spec$ be the
competency of the policy that selects actions uniformly at random. If maximum
causal entropy coincides with maximum entropy (\ref{eq:no_feedback}), the
likelihood of a path $\trc$ under $\policy_\spec$ is

```math \label{eq:max_ent_dist2}
\Prob(\trc\mid \policy_\spec, M) \propto
  \begin{cases}
    p_\spec / q_\spec & \text{if } \trc \in \spec\\
    (1 - p_{\spec})/(1 - q_\spec) & \text{if }\trc \notin \spec.
  \end{cases}
```

\emph{Proof.} For brevity, define the probability mass of just the state
transitions,

```math \label{eq:trace_weight}
w_\trc \eqdef \prod_{i=0}^{\tau-1}P(s_{i+1}\mid s_i, \act_i), \qquad W_\spec \eqdef \sum_{\trc \in \spec} w_\trc,
```

where $\trc = s_0 \xrightarrow{\act_0} s_1 \xrightarrow{\act_1} \ldots
\xrightarrow{\act_n} s_n$, and define $c \eqdef e^{\rat}$. By assumption,

$$Z_\spec\cdot p_\spec = 1\cdot\sum_{\trc \in \spec} c^1\cdot w_\trc + 0\cdot\sum_{\trc \notin \spec} c^0\cdot w_\trc = c W_\spec, \qquad Z_\spec = c^1 \sum_{\trc \in \spec} w_\trc + c^0\sum_{\trc \notin \spec} w_\trc = c W_\spec + W_{\neg \spec}.$$

Combining gives $Z_\spec = W_{\neg \spec}/(1 - p_\spec)$. If $\trc \notin
\spec$, then $e^{\rat \cdot \spec(\trc)} = 1$, so substituting into
\ref{eq:path_dist} gives
$\Prob(\trc\mid \policy_\spec, M, \trc \notin \spec) = w_\trc\cdot \frac{1 - p_\spec}{W_{\neg \spec}}$.
If $\trc \in \spec$ (so $W_\spec \neq 0$), then $e^{\rat} = Z_\spec p_\spec /
W_\spec$, and
$\Prob(\trc\mid \policy_\spec, M, \trc \in \spec) = w_\trc \cdot \frac{p_\spec}{W_\spec}$.
Finally, $q_\spec = W_\spec / W_{\true}$; substituting and factoring gives
\ref{eq:max_ent_dist2}.
````

```node
# \taxon{remark}
If the dynamics were deterministic, $q_\spec$ would be proportional to
$|\operatorname{concept}(\spec)|$. Then \ref{prop:ratio} coincides exactly
with the size principle from concept learning \cite{tenenbaum1999bayesian},
where the likelihood of drawing an element from a concept is inversely
proportional to its cardinality (size).
```

````node
# \taxon{remark}
Together, \ref{prop:ratio} and \ref{eq:path_dist} imply that, if
\ref{eq:no_feedback} holds, then

```math \label{eq:rationality_no_feedback}
\rat = \ln \frac{p_\spec}{1 - p_\spec} - \ln \frac{q_\spec}{1 - q_\spec} = \operatorname{logit}(p_\spec) - \operatorname{logit}(q_\spec),
```

where $\operatorname{logit}(p) = \ln\frac{p}{1 - p}$. So $\policy_\spec$ is
entirely determined by the assumed competency $p_\spec$ and the random-action
competency $q_\spec$.
````

### Likelihood of multiple demonstrations {#sec:0Sgg}

If the teacher gives a sequence of demonstrations $\Demos$, drawn i.i.d. from
\ref{eq:max_ent_dist2}, the log likelihood of $\Demos$
is\sidenote{We suppress the multinomial coefficient needed if two
demonstrations are the same; this term does not change as $\spec$ varies, so
it cancels when comparing specifications.}

```math \label{eq:max_ent_dist3}
\ln\Prob(\Demos\mid \policy_\spec, M) = N_\spec \ln\left(\frac{p_\spec}{ q_\spec}\right) + (m - N_\spec) \ln\left(\frac{1 - p_\spec}{ 1 - q_\spec}\right) + C,
```

where $N_\spec \eqdef \sum_{\trc\in \Demos}
\spec(\trc)$, we take $0\cdot \ln(\ldots) = 0$, and $C$ is a constant that does
not depend on $\spec$. If $\Demos$ is "representative", so that $N_\spec
\approx p_{\spec}\cdot|\Demos|$, we can approximate \ref{eq:max_ent_dist3} (up
to a $\spec$-independent normalization) as

```math \label{eq:max_ent_dist5}
\Prob(\Demos\mid \policy_\spec, M)\appropto \exp{\Big(m\cdot \KL\big (p_\spec~\|~q_\spec\big)\Big)},
```

where $\KL\big (p \mid\mid q\big) \eqdef p \ln\frac{p}{q} + (1-p)\ln
\frac{1-p}{1-q}$ is the information gain (KL divergence) between two Bernoulli
distributions with means $p$ and $q$.

Unfortunately, the approximation $|\Demos|\cdot p_\spec \approx N_\spec$
implies $p_{\neg \spec} = 1 - p_{\spec}$, which gives the undesirable
symmetry $\Prob(\Demos~|~M, \policy_\spec) = \Prob(\Demos~|~M,
\policy_{\neg \spec})$. To break this symmetry, we assert that the
demonstrator is at least as good as random, which gives the approximate path
distribution

```math \label{eq:max_ent_dist6}
\Prob(\Demos\mid \policy_\spec, M)\appropto \indicator{p_\spec \geq q_\spec}\cdot \exp{\Big(m\cdot \KL\big (p_\spec~\|~q_\spec\big)\Big)}.
```

```node
# \taxon{remark}
By Sanov's theorem, \ref{eq:max_ent_dist6} can be read as quantifying the
atypicality of the demonstrations under the random-action hypothesis
\cite{cover2012elements}. So we seek tasks where the demonstrations seem
"typical."
```

```node
# \taxon{remark}
This special case shows that relying on the likelihood alone overfits the
data. Consider two task specifications $\spec \subset \spec'$ consistent with
the same demonstrations. Since $\spec$ is a subset of $\spec'$, $q_\spec <
q_{\spec'}$, so, assuming the same competency for $\spec$ and $\spec'$, the
KL divergence in \ref{eq:max_ent_dist6} must decrease when we add the paths
that $\spec'$ has and $\spec$ does not.

We can mitigate this in several ways. We use a prior that exponentially favors
tasks with small size. Also, moving to domains where causal entropy does not
coincide with static entropy helps mitigate overfitting: for stochastic
domains, the MAP estimate must balance making the agent's actions look like
the only good moves against making the actions look not risky. The former
needs removing paths from $\spec$; the latter needs adding paths to $\spec$.
```

## Bibliographic notes {#sec:FaYs}

This chapter argued that Boolean specifications are an interesting way to
formalize tasks, addressing several limitations of arbitrary objective
functions: a lack of compositionality, explicit historical dependencies, and
a tight coupling with the dynamics. To address these, recent work has proposed
learning Boolean task specifications, e.g., logic or automata, which admit
well-defined composition, explicitly encode temporal constraints, and have
workspace-independent semantics. This literature's development mirrors the
historical path of reward-based research, adapting optimal control
\cite{DBLP:conf/cdc/KasenbergS17,DBLP:conf/rss/ChouOB20}, Bayesian
\cite{DBLP:conf/nips/ShahKSL18,DBLP:conf/icra/Yoon021}, and maximum (causal)
entropy \cite{DBLP:conf/nips/Vazquez-Chanlatte18,DBLP:conf/cav/Vazquez-Chanlatte20}
IRL approaches.

Interestingly, the generalized size principle in \ref{prop:ratio} connects
the Bayesian perspective of \cite{DBLP:conf/nips/ShahKSL18} with this work.
\cite{DBLP:conf/nips/ShahKSL18} represents tasks as a conjunction of logical
statements, with a Bayesian model whose likelihood odds ratio depends on the
relative number of conjunctions in the task. Since conjunction corresponds to
language intersection, more conjunctions correlate with a smaller concept
size, which in turn correlates with a smaller random-action competency.

The folk modeling tricks for handling violations (\ref{sec:tricks}) relate
this work to \cite{DBLP:conf/cdc/KasenbergS17}, which seeks to minimize
violations of a temporal logic formula, measured as the size of the path
substring we must remove to satisfy the task, relative to random actions. The
folk trick for modeling violations works similarly, by introducing
probabilistic transitions into the DFA, which ignores subsequences of the
string at the cost of extra description complexity for not transitioning to
the failure sink. \ref{prop:ratio} completes the connection by making the
comparison relative to random actions.

Finally, it often makes sense to use task specifications to define
constraints rather than objectives, e.g., run as fast as possible \emph{while
avoiding hurdles}. A parallel literature has emerged on learning constraints,
typically with a known reward, that explain expert demonstrations
\cite{DBLP:conf/iclr/ScobeeS20,DBLP:conf/wafr/ChouBO18,DBLP:conf/ccta/McPhersonSS21}.
The key difference is that, rather than changing the reward function, this
literature implicitly modifies the underlying MDP. Still, many of the
problems in this literature echo those above: the key missing ingredient is a
way to strategically explore a large representation class. The next chapter
addresses this gap.
