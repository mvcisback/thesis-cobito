# Finding Explanatory Specifications {#ch:DISS}

> For every complex problem there is an answer that is clear, simple, and wrong.
>
> — H. L. Mencken, journalist and satirist, 1880–1956

The introduction and the previous chapter argued that expert demonstrations are
an expressive way to informally specify a task. This chapter continues the study
of inferring, from demonstrations, a task represented by a formal specification —
an automaton or a temporal logic formula.

```figure \label{fig:episodic-learning}
\caption{Learning an unknown task specification — the automaton on the right — from a human demonstration.}
<img src="imgs/episodic_learning.svg" alt="A human demonstration on the left, an unknown task automaton on the right.">
```

The key difficulty is how to search an intractably large — often infinite —
representation class. Unlike the reward setting, the discrete nature of automata
and logic, together with the assumed a-priori ignorance of the memory the task
needs, makes a gradient-based approach either intractable or inapplicable.
Current work instead enumerates representations syntactically
\cite{DBLP:conf/nips/Vazquez-Chanlatte18,DBLP:conf/rss/ChouOB20,DBLP:conf/nips/ShahKSL18,DBLP:conf/icra/Yoon021}
or hill-climbs through simple probabilistic mutations
\cite{DBLP:conf/cdc/KasenbergS17}.

## Contributions {#sec:diss-contributions}

This chapter introduces a family of approximate algorithms, \emph{Demonstration
Informed Specification Search} (DISS). DISS asks: given the current candidate
task, which counter-factuals still need an explanation? For example, we may need
to explain why the agent did not take a particular shortcut. The answer is a
series of supervised learning problems, where each surprising counter-factual is
addressed — the shortcut is not taken because it is a negative example.

```custom[latexfig] \label{fig:diss-overview}
\caption{A DISS cycle: guess a task, find a counter-factual that needs explanation, and choose which counter-factuals to focus on next.}
imgs/diss_overview3.pdf_tex
```

The result is an approximate solution to the \ref{prob:tifd} of the previous
chapter. After we describe DISS, two experiments confirm that it searches
efficiently for tasks that explain the demonstrations, even in a large and
unstructured representation class such as DFAs, and even given unlabeled and
possibly incomplete demonstrations. We close the chapter with how to handle
violations of the Luce axiom, that is, redundant actions.

\taxon{remark}

### Why DFAs? {#rem:why-dfas}

We use DFAs as the representation class in our experiments for three reasons.
First, a DFA encodes memory explicitly, which makes the contribution of
identifying the relevant memory clear. Second, every other technique for learning
a finite path property from demonstrations works on a syntactically defined
class, so learning DFAs is understudied in this context. Third, DFAs are a very
large and mostly unstructured class, so they let us study the search efficiency
of DISS without baking in much inductive bias. By comparison, the existing
techniques each carry the inductive bias of their own logic, so a direct
comparison would confound search efficiency with that bias.

## Running example {#sec:diss-running-example}

```macros \label{def:diss-tiles}
We write $\blueTile$ for a water tile and $\brownTile$ for a drying tile.

\def\blueTile{\textcolor{#afafff}{\blacksquare}}
\def\brownTile{\textcolor{#f4a460}{\blacksquare}}
```

Let us return to the gridworld of the previous chapter.

```figure \label{fig:gw8x8}
\caption{The 8-by-8 gridworld. The black path is the prefix of an episode.}
<img src="imgs/gw8x8.svg" alt="An 8-by-8 gridworld with a black demonstrated path and colored tiles.">
```

Consider an agent in the 8-by-8 gridworld above. It can try to move up, down,
left, or right. With probability $\tfrac{1}{32}$ the wind pushes the agent down,
whatever action it takes. The black path is the prefix of an episode: the agent
tries to move left, slips onto a blue tile ($\blueTile$), visits a brown tile
($\brownTile$), and then moves down.

Given the black demonstration, call it $\trc_b$, and the prior knowledge that the
task makes the agent avoid red tiles ($\redTile$), what task — as a DFA —
explains the agent's behavior?

Inspecting the demonstration, we might hypothesize that the complete path, formed
by extending $\trc_b$ with the grey dashed line to $\yellowTile$, is a positive
example of the task. By Occam's razor we might then conjecture that the task is
just to reach $\yellowTile$ and avoid $\redTile$. But under that hypothesis, and
with a temporal discount, $\trc_b$ is surprising. The detour to visit
$\brownTile$ looks unjustified, and the agent should have taken the red dashed
path straight to $\yellowTile$.

To account for this, we might conjecture that the true task requires a visit to
$\brownTile$ after a visit to $\blueTile$ — which explains why the agent avoids
the red dashed path. The demonstration is also less surprising if the task makes
the agent avoid red tiles, which explains why it avoids the light-blue dotted
path.

```figure \label{fig:target-dfa}
\caption{The task recovered by this reasoning, as a DFA.}
<img src="imgs/true_dfa.svg" alt="A deterministic finite automaton encoding the recovered task.">
```

The result is the task that the DFA above represents. A later chapter
systematizes this reasoning into a learner that recovers an explanatory DFA from
a demonstration.
