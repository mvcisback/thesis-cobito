# Introduction {#ch:intro}

> Since I am neither a neurologist nor a psychiatrist, but a mathematician, the
> work that follows requires some explanation and justification.
>
> — John von Neumann, \emph{The Computer and the Brain}, 1957

Consider a car turning at a busy intersection. Ideally, the car should be able to
infer the intent of other agents, such as cars and pedestrians, from past
observations, and infer what assumptions and inferences the other agents are
making about the world. For example, is the pedestrian assuming two vehicles will
not enter the intersection at the same time? Similarly, we would like the car to
communicate its own objective, assumptions, and constraints to other agents, e.g.
vehicles and pedestrians.

Such scenarios involving cyber-physical systems (CPS) are becoming increasingly
ubiquitous, with applications ranging from driving to manufacturing
\cite{DBLP:conf/esweek/LeeS10}. This ubiquity brings an appetite for "auditable"
systems whose high-level intent and assumptions can be easily communicated to
other agents, e.g., human collaborators or regulators.

Taking a step back three questions naturally arise:

1. How should intent and assumptions be represented?
2. By what means should the representations be communicated, e.g., natural
   language, visual cues, etc?
3. How should the answers to (1) and (2) change when talking to humans versus
   another CPS?

For the sake of brevity, let us refer to the intended behavior of an agent (along
with any implicit assumptions about the world) as a task.

## Thesis Preview {#sec:0GCT}

In this dissertation, we will setup the problems of learning and teaching tasks,
represented as formal specifications, using demonstrations. This will require
bringing in theory from many disparate areas ranging from grammatical inference
\cite{de2010grammatical} to maximum entropy inverse reinforcement learning
\cite{mceThesis}. We shall see that the core technical difficulties in realizing
this vision are the inherent combinatorics of task specification representations,
e.g. automata, logic, and programs. In particular, we shall address the
combinatorics in (i) predicting the behavior of agents trying to perform a task;
(ii) searching for task specifications that explain the demonstrations; and (iii)
optimizing trajectories to be more pedagogic. These problems, referred to as
Control, Learning, and Teaching, respectively, naturally build on each other, and
this dependence will be reflected in the exposition.

## Representing tasks {#sec:WPSz}

Examining the literature, one finds a variety of possible ways to represent
tasks \cite{kalman1964linear, DBLP:conf/iros/HorowitzWM14, DBLP:conf/icml/VermaMSKC18, DBLP:conf/icml/IcarteKVM18, watanabe2021probabilistic}.
For example, the problem of inferring the intent of agents optimizing some real
valued objective in a dynamical system has a rich and well developed literature,
with roots dating back to the early work on Inverse Optimal Control
\cite{kalman1964linear}. Within this paradigm, the intent and assumptions of the
agent are intimately tied into the way that optimizing the objective interacts
with the world model. When reasoning about such systems, either for collaboration
or for regulation, this tight coupling between objective and dynamics proves
problematic: the particular task encoded by the objective may change due to simple
changes in the environment.

```macros \label{def:tiles}
We write $\yellowTile$ for a goal tile and $\redTile$ for a hazard tile.

\def\yellowTile{\textcolor{#e8c200}{\blacksquare}}
\def\redTile{\textcolor{#ff8b8b}{\blacksquare}}
```

```figure \label{fig:yr2}
\caption{A gridworld whose Markovian reward encodes visiting $\yellowTile$ and avoiding $\redTile$.}
<img src="imgs/with-recharge.svg" alt="gridworld with a recharge station" width="240">
```

```figure \label{fig:bug2}
\caption{Removing a recharge station makes the agent cut through $\redTile$ to another station.}
<img src="imgs/missing-recharge.svg" alt="gridworld missing a recharge station" width="240">
```

\taxon{example}

### The brittle recharge reward {#ex:recharge}

Consider the gridworld of \ref{fig:yr2}, where the agent moves up, down, left, or
right and the episode ends at each step with probability $0.69$. The agent
optimizes the expected sum of state rewards — shown in each tile — encoding the
task of visiting $\yellowTile$ and avoiding $\redTile$; concretely, a robot that
must recharge while avoiding lava. Removing a recharging station from the
workspace (\ref{fig:bug2}) makes the agent enter the lava to take a shortcut to
another station.

## Representing tasks as specifications {#sec:zGkC}

An alternative approach, championed throughout this thesis, is to make the set of
desirable behaviors explicit.\sidenote{Again, subject to a common vocabulary for
describing observations.} Realized by a formal specification, this set gives a
dynamics-independent classification of behaviors as good or bad. The relative
preferences induced by the dynamics now only encode how risky a behavior is: the
possibility of slipping makes a good path near the ledge worse than a good path
away from it.\sidenote{Formally, the ordering is lexicographic — first a
dynamics-independent split into good and bad, then a dynamics-dependent preference.}
Even when two world models disagree on the ordering, the set of acceptable
behaviors is stable, eliminating entire classes of reward-hacking bugs
\cite{DBLP:journals/corr/abs-1711-09883}. Focusing on Boolean specifications also
lets us express temporal dependencies, exploit compositionality, and reuse formal
methods for planning and verification \cite{seshia-arxiv16}.

## Modeling agents {#sec:rW5R}

First and foremost, the Control (or Prediction) problem asks: how can one robustly
and efficiently predict the behavior of an agent performing a task in a given
workspace? We wish to model purposefulness, informally:

\taxon{definition}

### Purposefulness {#def:purposeful}

There must be, on the part of the behaving agent: (a) a desire, whether actually
felt or not, for some object, event, or state of affairs as yet future; (b) the
belief, whether tacit or explicit, that a given behavioral sequence will be
efficacious as a means to the realization of that object, event, or state of
affairs; and (c) the behavior pattern in question \cite{taylor1950purposeful}.
