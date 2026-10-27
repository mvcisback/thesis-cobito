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

Beyond this brittleness, the nature of assumptions or temporal relationships
is left implicit, making explicit communication with other agents — which
may use different world models — unnecessarily brittle. At the risk of
over-emphasizing: just because two agents share a common high-level
description of behaviors does not mean they agree on the relative ordering
of those behaviors. One agent might model time as continuous, another as
discrete, and a third as discrete but at a different resolution; one agent
might model the dynamics as deterministic while another uses probabilistic
dynamics. These modeling details change the \emph{relative weights} of
behaviors, e.g., a path might seem slightly shorter under one model than
another. Further, there is no general way to associate a set of "acceptable"
behaviors with the ordering that a Markovian (state-based) reward induces
over behaviors \cite{DBLP:journals/nips/Abel22} — i.e., with a behavior being
acceptable so long as it performs at least as well as a given set of
behaviors under the given world model.

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

As the chapter epigraph suggests, this dissertation makes no claim to deep
insight into the nature of complex agents such as humans — it is not written
from the perspective of a neurologist or a psychiatrist. Fortunately, unlike
the natural sciences, where an observed gap between model and theory might be
called a catastrophe \cite{ehrenfest1911zuge}, the goal here is only to predict
behavior in a way that minimizes how hard it is to describe the actions of a
competent agent. Technically, this is achieved by leveraging the established
theory of maximum causal entropy for modeling purposeful behavior in
sequential decision processes \cite{mceThesis}: operationally, this theory
prescribes forecasting an agent's actions using an entropy-regularized policy
that trades off performance for randomness (entropy). The key detail is that
this theory gives predictions that minimize the worst-case log-loss — the
number of bits needed to describe the behavior — so it does not matter
whether the agent is human or is using a slightly different world model for
planning. So long as the dynamics model is expressive enough to capture
common behavior, the enforced guarantees will hopefully paper over modeling
discrepancies, an observation formalized in the robust entropy-regularized
control literature \cite{DBLP:journals/corr/abs-2103-06257}.

## Communicating tasks {#sec:communicating-tasks}

```figure \label{fig:communication}
\caption{Using demonstrations to communicate a task specification. The human
(left) has a natural-language description of the task in mind, and the robot
(right) maintains a binary encoding of a task specification.}
<img src="imgs/episodic_communication.svg" alt="A human and a robot communicating a task via demonstration" width="420">
```

The learning and teaching problems successively build on the control problem
to communicate formal task specifications using demonstrations, as
illustrated in \ref{fig:communication}. The learning problem asks: given a
collection of expert demonstrations, which formal task specifications explain
the expert's behavior? Because the problem statement is ambiguous, we seek a
distribution of specifications that plausibly explain the agent's behavior.

Next, because formal task specifications can be hard to understand, the
teaching problem asks: can one generate a small number of pedagogic
demonstrations\sidenote{Potentially supplemented with formal or
natural-language descriptions.} that help a user understand a task? To
ground the notion of a pedagogic example, we lean heavily on the literature
on pragmatics \cite{grice1975logic}, legibility
\cite{DBLP:conf/hri/DraganLS13}, and showing vs. doing
\cite{DBLP:conf/nips/HoLMCA16}. The core idea is for the teacher to simulate
the learner, in order to give demonstrations that make the true task easier
to infer.

## Contributions {#sec:intro-contributions}

This thesis contributes algorithms and theoretical machinery for
systematically mitigating the combinatorial explosions inherent in (1)
finding task specifications that explain an agent's behavior, (2) finding
pedagogic demonstrations that help humans infer the specification, and (3)
robustly predicting the behavior of an agent adhering to a specification.
The contributions are:

\strong{Maximum Causal Entropy Specification Learning from Demonstrations}
(\cite{DBLP:conf/cav/Vazquez-Chanlatte20}, \ref{ch:task_spec}): We propose
using the principle of maximum causal entropy to formulate the problem of
learning task specifications from expert demonstrations in Markov decision
processes. In the context of specification mining \cite{Li:EECS-2014-20} and
grammatical inference \cite{de2010grammatical}, demonstrations are an
ergonomic, sample-efficient way to communicate formal languages and
specifications. The key contribution is a formulation compatible with a
Bayesian pipeline that supports unlabeled and even incomplete demonstrations.
In the context of inverse reinforcement learning
\cite{DBLP:conf/icml/NgR00}, Boolean task specifications are a class of
sparse, memory-augmented rewards with explicit support for temporal and
Boolean composition — this composition enables incremental learning, and the
Boolean episode-level semantics eliminate entire classes of reward-hacking
bugs.

\strong{Maximum Entropy Specification Learning from Demonstrations}
(\cite{DBLP:conf/nips/Vazquez-Chanlatte18}, \ref{ch:task_spec}): We study the
special case where maximum causal entropy and maximum entropy approximately
coincide, e.g., under deterministic dynamics. This yields a generalization of
the size principle from concept learning \cite{tenenbaum1999bayesian} to
stochastic dynamics, and an information-theoretic interpretation of the model
as quantifying how atypical the demonstrations are under the random-action
hypothesis \cite{cover2012elements}.

\strong{Demonstration Informed Specification Search}
(\cite{DBLP:journals/corr/abs-2112-10807}, \ref{ch:DISS}): We contribute a
family of approximate algorithms (DISS) that systematically reduce learning
task specifications from demonstrations to a series of supervised
task-specification learning problems. Compared to prior work, DISS can search
very large and unstructured concept classes, e.g., automata, even without
strong syntactic priors, and needs only black-box access to a maximum
(causal) entropy planner and a supervised task-specification learner — so the
algorithm is agnostic to the underlying dynamics model and task-specification
representation. This flexibility enables both efficient learning and teaching
of task specifications. A concrete instance
\cite{Vazquez-Chanlatte_Demonstration_Informed_Specification} of this
algorithm, for specifications in the form of automata, gives empirical
evidence that the approach scales to combinatorially explosive classes of
tasks.

\strong{Teaching Specifications using Demonstrations} (\ref{ch:teach}): We
adapt the showing-vs-doing framework \cite{DBLP:conf/nips/HoLMCA16}, which,
given a model of the learner, gives a principled way to measure how pedagogic
a series of expert demonstrations is — a formalization of the problem of
teaching specifications using demonstrations. To handle large spaces of task
specifications, e.g., automata, we provide a counterexample-driven algorithm,
using DISS as a surrogate learner, for finding pedagogic demonstrations.
Finally, an online human study, in which participants were asked to label
behaviors as good or bad after seeing a series of demonstrations of an
unknown task specification, shows that participants given pedagogic
(showing) demonstrations performed better than a baseline that simulates
expert behavior (doing).

\strong{Control Improvisation in Stochastic Games}
(\cite{DBLP:conf/rss/Vazquez-Chanlatte21}, \ref{ch:erci}): We study Entropic
Reactive Control Improvisation (ERCI), a decision variant of maximum causal
entropy policy synthesis specialized to task specifications in stochastic
games, giving an algorithmic way to trade performance against randomization.
Stochastic games combine adversarial and probabilistic behavior in an
environment, enabling modeling flexibility that facilitates model
compression and applicability to new domains, e.g., using probability ranges
rather than point probabilities to combine similar states or actions, or to
explicitly capture uncertainty in the dynamics model. We also provide
algorithms to decide ERCI whose certificates are policies that maximize
causal entropy subject to the performance constraints.

\strong{Stochastic Games as Circuits}
(\cite{DBLP:journals/corr/abs-1903-09354}, \ref{ch:circ}): To succinctly
represent stochastic games with history-dependent task specifications, we
study modeling probabilistic transition systems as circuits. The result is a
framework for analyzing queries about stochastic games — e.g., the
probability of satisfying the task specification under actions applied
uniformly at random — using tools such as Boolean satisfiability (SAT)
solvers \cite{DBLP:journals/jacm/DavisP60,DBLP:journals/cacm/MalikZ09} and
binary decision diagrams \cite{DBLP:journals/tc/Bryant86,DBLP:journals/csur/Bryant92}.

\strong{Stochastic Games as BDDs} (\cite{DBLP:conf/cav/Vazquez-Chanlatte20},
\ref{ch:bdd}): Building on the circuit encoding of stochastic games, we study
the implications of representing that circuit as a binary decision diagram
(BDD). The result is a succinct encoding of a time-unrolled stochastic game
well suited for entropy-regularized planning and ERCI. We also show that the
worst-case size of these BDDs grows linearly in the horizon and
quasi-linearly in the number of actions, and, because BDDs support function
composition, that the horizon of the time-unrolled stochastic game can be
incrementally expanded — enabling work with a compressed representation of
the dynamics model throughout the planning process.

## Reader's Guide {#sec:readers-guide}

```figure \label{fig:thesis_overview}
\caption{An overview of the dissertation's structure.}
<img src="imgs/thesis_overview.svg" alt="Overview of the thesis structure" width="280">
```

The structure of this dissertation reflects the three problems and
contributions above — Learning, Teaching, and Control — as shown in
\ref{fig:thesis_overview}. Sections not necessary to understand the main
contributions are marked with $\dagger$; these can be skipped on a first
reading.

### Preliminaries {#sec:readers-guide-prelims}

We start with prelude chapters (\ref{ch:concepts} and \ref{ch:dyn-prelim})
that recount the technical machinery needed for the rest of the dissertation:
formal tools for encoding concept classes, modeling stochastic workspaces,
and robustly predicting the behavior of purposeful agents.

### Learning and Teaching {#sec:readers-guide-learning-teaching}

Next comes \ref{part:learn}, which covers the learning and teaching problems.
\ref{ch:task_spec} opens the part by formally introducing task specifications
and the changes needed to existing theory on entropy-regularized planning and
learning from demonstrations to incorporate them, leading to a formal
statement of the learning problem, modeling tricks that highlight the
expressiveness of stochastic dynamics and task specifications, and an
analysis of the deterministic-dynamics special case. Because task
specifications are discrete and non-Markovian, they are ill-suited to
standard learning-from-demonstration algorithms; to address this,
\ref{ch:DISS} derives a systematic reduction from learning from
demonstrations to a series of supervised learning problems, giving a family
of approximate algorithms called Demonstration Informed Specification Search
(DISS). \ref{ch:teach} closes the part by formalizing the teaching problem
and giving a counterexample-driven algorithm, using DISS as a surrogate
learner, for finding pedagogic demonstrations.

### Prediction and Control {#sec:readers-guide-prediction-control}

The results in \ref{part:learn} assume black-box access to a maximum causal
entropy planner for predicting an agent's actions. \ref{part:control} studies
how to efficiently perform maximum causal entropy likelihood estimates in
stochastic games. \ref{ch:erci} starts with control improvisation — the
decision problem corresponding to entropy-regularized planning in Markov
decision processes, interval Markov decision processes, and, more generally,
stochastic games — giving planning algorithms that scale in the size of the
time-unrolled stochastic game. To keep that size tractable, \ref{ch:circ}
changes perspective and explores modeling probabilistic transition systems as
probabilistic circuits, setting the stage for \ref{ch:bdd}, which stores
compressed representations of probabilistic transition systems using binary
decision diagrams (BDDs) — on which, as we shall see, maximum causal entropy
planning can be done directly.

## Bibliographic Notes {#sec:intro:bib}

Each chapter ends with bibliographic notes connecting it to the wider
literature and historical context. This chapter's notes are different: they
also acknowledge the contributions of peers and mentors, in roughly
chronological order.

### Thesis conceptualization {#sec:intro-bib-conceptualization}

The idea of learning task specifications from demonstrations was inspired by
the VeHICaL NSF Cyber-Physical Systems (CPS) Frontier project. The formalism
in terms of maximum entropy inverse reinforcement learning grew out of
interactions with Anca Dragan and Dorsa Sadigh — particularly Anca's class on
algorithmic human-robot interaction — and was then mentored and encouraged by
Susmit Jha and Ashish Tiwari at SRI International. Discussions with Mark Ho
then refined the theory and motivations, leading to the initial work
\cite{DBLP:conf/nips/Vazquez-Chanlatte18} on learning task specifications
from demonstrations — the special case of maximum entropy task-specification
learning among the contributions above. The connection to the size principle
is due to Tom Griffiths.

### The road to Maximum Causal Entropy Planning {#sec:intro-bib-causal-entropy-road}

Generalizing to the more complex causal-entropy setting required developing
additional machinery to efficiently compute maximum causal entropy policies.
The first insight — modeling Markov decision processes as circuits — required
a non-trivial amount of engineering and would not have been possible without
the mentorship of Markus Rabe; these insights form the basis of \ref{ch:circ}
and \cite{model_counters_guide}. This circuit encoding then led to the
BDD-based maximum causal entropy planner in \ref{ch:bdd} and
\cite{DBLP:conf/cav/Vazquez-Chanlatte20}. The generalization to the
stochastic-game setting \cite{DBLP:conf/rss/Vazquez-Chanlatte21} was joint
work with Sebastian Junges, inspired by Daniel Fremont's work on Reactive
Control Improvisation \cite{DBLP:conf/cav/FremontS18}.

### Learning and teaching, revisited {#sec:intro-bib-learning-teaching}

With a maximum causal entropy planner in hand, the next question was how to
efficiently search for tasks given very large concept classes — solved in
\ref{ch:DISS} using the DISS algorithm \cite{DBLP:journals/corr/abs-2112-10807}.
The first versions of what became DISS originated from discussions with Gil
Lederman, with later refinements thanks to the mentorship of Steven
Piantadosi; the SAT-based DFA concept sampler DISS uses in \ref{ch:DISS} was
made possible with the help of Ameesh Shah and Vint Lee.

The main ideas for teaching using demonstrations again originate from
interactions with Anca Dragan, with the ultimate version drawing heavily on
Mark Ho's work on showing vs. doing \cite{DBLP:conf/nips/HoLMCA16}. The core
of the algorithm in \ref{ch:teach} was conceived shortly after the initial
work on maximum entropy task-specification inference; an early version of
the ideas appeared in \cite{teachingCphs}, joint work with Mark Ho and Tom
Griffiths. A proper treatment of these ideas, though, needed a robust and
scalable way to learn task specifications from demonstrations — the missing
ingredient DISS provided, resulting in the algorithm in \ref{ch:teach}. The
corresponding human study owes no small part to Mark Ho, Ameesh Shah, and Tom
Griffiths.

Finally, implicit in every contribution here is the influence of Sanjit
Seshia. It was his training and mentorship — particularly in formal methods —
that made many seemingly combinatorially intractable problems seem
reasonable, and his mentorship that crystallized the motivation for learning
formal specifications.
