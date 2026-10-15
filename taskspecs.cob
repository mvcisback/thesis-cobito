# Specifications from Demonstrations

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
