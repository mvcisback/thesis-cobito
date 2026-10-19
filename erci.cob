# Improvisation in Stochastic Games {#ch:erci}

> Improvisation is too good to leave to chance.
>
> — Paul Simon (Musician, 1941-)

```macros \label{def:erci-notation}
We write $\pOne$ for the ego player and $\pTwo$ for the environment player, with $\pOneSched$ and $\pTwoSched$ for their policies. We write $\scp$ for a performance (a satisfaction probability), $\rndp$ for a randomness level, and $\scthreshold$ and $\randomness$ for the vectors of them. A star marks the optimum, and a minus sign the minimum. We write $\solutions$ for the set of achievable points and $\pareto{\solutions}$ for its Pareto front.

\def\pOne{\mathsf{ego}}
\def\pTwo{\mathsf{env}}
\def\pOneSched{{\sigma_{\pOne}}}
\def\pOneSchedPrime{{\sigma'_{\pOne}}}
\def\pTwoSched{{\sigma_{\pTwo}}}
\def\sg{\mathcal{G}}
\def\target{s_{\top}}
\def\sink{s_{\bot}}
\def\sched{\sigma}
\def\path{\xi}
\def\supp{\mathsf{support}}
\def\Succ{\mathsf{Succ}}
\def\player{\mathsf{i}}
\def\Paths{\mathsf{Paths}}
\def\POnePaths{[\mathsf{Paths}]_{\pOne}}
\def\PTwoPaths{[\mathsf{Paths}]_{\pTwo}}
\def\PlayerPaths{[\mathsf{Paths}]_{\player}}
\def\RV[x]{{\mathcal{\x}}}
\def\cmid{\mid}
\def\hard{\psi}
\def\soft{\varphi}
\def\ppthreshold{\mathbf{d}}
\def\droneEnv{{D_{\text{new}}}}
\def\droneEgo{{D_{\text{test}}}}
\def\indicator[x]{[\x]}
\def\smoothmax{\operatorname*{\mathrm{smax}}}
\def\pareto[x]{\mathcal{F}_{\x}}
\def\solfuncp{f_{\mathbb{S}}}
\def\rndp{h}
\def\rndmin{h^{-}}
\def\rndopt{h^{*}}
\def\randomness{\mathbf{h}}
\def\scp{p}
\def\scmin{p^{-}}
\def\scopt{p^{*}}
\def\scthreshold{\mathbf{p}}
\def\solutions{\mathbb{S}}
```

In this chapter, we study how to compute maximum causal entropy policies given
a planning horizon and a task specification. Technically, this will be done by
framing the problem as instance of control
improvisation \cite{DBLP:conf/cav/FremontS18,DBLP:conf/fsttcs/FremontDSW15}
over stochastic games.
In the control improvisation framework, one specifies a controller with three
types of declarative constraints. (i) \emph{Hard constraints} that, as in the
classical setting, must hold on every execution, (ii) \emph{soft constraints}
that should hold on most executions, and (iii) \emph{randomization constraints}
that ensure that a synthesized policy does not overcommit to a particular
action or behavior. The key challenge when solving control improvisation is
that randomization and performance, in the form of soft constraints, constitute
a natural trade-off.

Control improvisation was originally proposed for nondeterministic
domains where uncertainty is resolved adversarially. This assumption is often
too restrictive and leads (together with the soft/hard constraints) to
conservative policies or common situations in which the synthesis algorithm
cannot be employed at all. To overcome this weakness, in this chapter, we
develop a theory of control improvisation in stochastic games which admit
arbitrary \emph{combinations} of nondeterministic and probabilistic
uncertainty, including unknown or imprecise transition probabilities.

Technically, we formulate our problem on \emph{simple stochastic
games} \cite{DBLP:conf/dimacs/Condon90}, an extension of \emph{Markov decision
processes} (MDPs) that divides states between controllable states and
uncontrollable (or adversarially controlled) states. \emph{Soft constraints}
are finite horizon temporal properties with a threshold on the worst-case
probability of the property holding by the end of the episode. \emph{Hard
constraints} are soft constraints to be satisfied with probability 1. In
contrast to other work on control improvisation, we adopt causal entropy as a
natural means to formalize \emph{randomness constraints}.
In doing so, we are able to realize the entropy regularized planners
required by the learning and teaching algorithms in \ref{part:learn}{Part: Learning and Teaching}.

We refer to this variant of control improvisation as \emph{Entropic Reactive
Control Improvisation} (ERCI) and show that ERCI conservatively extends
reactive control improvisation \cite{DBLP:conf/cav/FremontS18} to stochastic
games. More precisely, entropy can be used in the non-stochastic setting and
yields results analogous to reactive control improvisation. ERCI also extends
classical policy synthesis in stochastic games, i.e. synthesis in absence of
randomness constraints as, e.g., implemented in
PRISM-games \cite{DBLP:journals/sttt/KwiatkowskaPW18}.

## Contributions {#sec:4KRW}

In summary, this chapter provides Entropic Reactive Control Improvisation
(ERCI), a decision variant of entropy regularized planning specialized for task
specifications in stochastic games. ERCI provides an algorithmic way to trade
performance and randomization in stochastic games. Stochastic games combine
both adversarial and probabilistic behavior in an environment, enabling
modeling flexibility, which facilitates model compression and applicability to
new domains, e.g., using probability ranges rather point probabilities to
combine similar states/actions or explicitly capture uncertainty in the
dynamics model. Finally, this work contributes the necessary technical
machinery and a prototype implementation. Combined, our theoretical and
empirical analysis suggest that the ERCI framework contributes a tractable and
flexible modeling formalism.

## Overview {#sec:wllX}

This chapter is structured as follows. We begin with a motivating example
(\ref{sec:motivating}). This motivating example will highlight the
potential application of ERCI in domains outside behavior predication, and in
particular, the generation of random behavior for testing systems.
Furthermore, this example will demonstrate the modeling flexibility derived from
supporting stochastic games. Next, we provide preliminaries and formalize the
ERCI problem statement in \ref{sec:problem}, cast ERCI as a
multi-objective optimization problem, and study properties of the solution set
in \ref{sec:convex}. With this technical machinery developed,
\ref{sec:mdps} re-frames existing literature on maximum causal entropy
inference and control to derive an algorithm for MDPs. Then in
\ref{sec:erci-sgs}, we provide an algorithm for the general case of stochastic
games. We conclude with an empirical evaluation (\ref{sec:empirical}) and
a comparison with related work, e.g., other control improvisation formulations
(\ref{sec:related}). Proofs are provided in \ref{sec:proofs_erci}.

## Motivating Example {#sec:motivating}

```custom[latexfig] \label{fig:motivating}
\caption{Illustration of delivery drone testing example. The goal is to synthesize a policy for the bottom left (white circle) drone to test the controller of the top right (black square) drone. Ideally, the synthesized policy should be as randomized as possible to avoid testing bias.}
imgs/motivating_example.pdf_tex
```

We consider a scenario in which a regulatory agency wishes to certify the
safety and performance of a new delivery drone $\droneEnv$. As part of the
process, the agency runs $\droneEnv$ through a series of tests. For example,
given a certain delivery route, the agency investigates whether $\droneEnv$
successfully delivers packages while avoiding \emph{other} delivery drones. To
execute this test, the agency decides to synthesize a controller for another
delivery drone, $\droneEgo$, to test if $\droneEnv$ can be certified.

Concretely, suppose we command $\droneEnv$ to continuously visit four houses in
some workspace. We illustrate such a scenario in \ref{fig:motivating}, in
which $\droneEnv$ and $\droneEgo$ are shown as black square and white circle
drones respectively. For this test scenario, the regulatory agency wishes to
examine how $\droneEnv$ responds to delivering packages to the red houses in the
presence of $\droneEgo$. In particular, it would like to let $\droneEgo$ also
deliver packages while avoiding $\droneEnv$. Importantly, to properly exercise
$\droneEnv$, $\droneEgo$ should show a \emph{variety} of behaviors meeting the
specification, and the behaviors should not be biased to any behavior beyond
the given specification.

With the ERCI framework, the agency may formalize the above scenario with the
following constraints on $\droneEgo$:

1. (\emph{hard constraint}) Ensure that the two drones \emph{never} collide.
2. (\emph{soft constraint}) With probability at least $.8$, visit all four houses within 10 minutes.
3. (\emph{randomness constraint}) Perform this task as unpredictably as possible.

What remains is to synthesize a controller given the constraints \emph{and} the
world model. At this point, it is worth examining more closely how one models
$\droneEnv$'s controller when synthesizing $\droneEgo$. We illustrate by
examining three models. In all models, we capture the behaviors of $\droneEnv$
and $\droneEgo$. We focus on $\droneEnv$, but the ideas carry over to modeling
the actuation of $\droneEgo$.

### Nondeterministic Model {#sec:T4Ay}

The simplest approach to modeling is not to make any assumptions about
$\droneEnv$ beyond what already has been established. Here, we model that the
houses are visited either in clockwise or counter-clockwise order but that it may
switch direction at \emph{any time}. Such a model is too liberal and our
assumptions under which we plan the behavior for $\droneEgo$ is too pessimistic,
which leads to a bad test set. First, if $\droneEnv$ is unrestricted, then
$\droneEgo$'s behavior is severely limited, as it must behave conservatively to
avoid collisions under all possible motions by $\droneEnv$ (even very unlikely
motions). This limitation restricts the variance of its behavior, and it will
not test $\droneEnv$'s true behavior. A purely non-deterministic model for
$\droneEnv$ thus may not lead to the synthesis of adequate behavior for
$\droneEgo$.

### Stochastic Model {#sec:JwyX}

Rather than the pessimistic nondeterministic (or adversarial) assumption, we may
collect data about $\droneEnv$ and construct a stochastic model, e.g., using
inverse reinforcement learning \cite{DBLP:conf/icml/NgR00}. Concretely (but
simplified), after examining the data, one observes that $\droneEnv$ appears to
flip a biased coin with fixed probability $p$ whenever it reaches a house to
decide whether or not to turn around. This models $\droneEnv$ much more
precisely, and allows for more targeted test by $\droneEgo$.

### Nondeterministic and Stochastic Model {#sec:KOfy}

However, a natural criticism for stochastic models is the dependence on
\emph{fixed} probabilities. Obtaining such probabilities with confidence
requires many tests which defeat the purpose of our test setup, and making
point-estimates from little data may not create faithful models of the actual
behavior. In absence of enough (or reliable) data, we can arbitrarily combine
nondeterministic choices and stochastic behavior. We may use stochastic
abstractions for parts that we can faithfully model, and nondeterministic
behavior in absence of data. In particular, we support interval-valued
transition probabilities. Consider the delivery-drone $\droneEnv$. Rather than
inferring a point-estimate from data, we may have inferred that the probability
of turning around is in the interval $[p - \varepsilon, p + \varepsilon]$ for
adequate values of $p$ and $\varepsilon$. Furthermore the actual probability may
even depend on aspects of the current state.

### ERCI as a unifying framework {#sec:4jKv}

The strength of the (entropy-guided) control improvisation framework is that we
can combine all these aspects into a single and thus flexible computational
model. In particular, the models above are captured by a 2-player game, a
1.5-player game (MDP) and a 2.5-player game (stochastic game, SG), respectively.
In all cases, the first player controls the behavior of $\droneEgo$ and this
controller is to be synthesized. We contribute an algorithm that synthesizes a
controller that maximally randomizes in all of the formalisms discussed above.
In the coming sections, we shall formally define the ERCI problem, highlight that
there is an implicit trade-off between performance of the soft constraint and
unpredictability, and provide an algorithm solving ERCI for SGs.

## Problem Statement {#sec:problem}

This section formalizes the novel Entropic Reactive Control Improvisation (ERCI)
problem.

### Stochastic Games {#sec:LuqU}

We start with some necessary definitions and notations on stochastic games
which generalize the MDPs defined in \ref{ch:dyn-prelim}{Workspaces and Decision Processes}.

```node
# \taxon{definition} \label{def:stochastic-game}
A (2.5-player) \emph{stochastic game} (SG) is a tuple $\sg = \langle S,
s_0, \Act, P \rangle$. The finite set of \emph{states} $S = S_\pOne \cup
S_\pTwo$ is partitioned into a set $S_\pOne$ of (controlled)
$\pOne$-states and a set $S_\pTwo$ of (uncontrolled)
$\pTwo$-states. $s_0 \in S_\pOne$ is the \emph{initial state}, $\Act$ is a
finite set of \emph{actions}, and $P\colon S \times \Act \rightarrow
\Distr(S)$ is the \emph{transition function}. For simplicity of
exposition, we assume w.l.o.g. that controlled and uncontrolled
states alternate. Thus, $P$ is defined by two \emph{partial} transition functions:
$P_\pOne\colon S_\pOne \times \Act \rightarrow \Distr(S_\pTwo)$,
$P_\pTwo\colon S_\pTwo \times \Act \rightarrow \Distr(S_\pOne)$. We
identify the available actions\sidenote{We use a partial function as we explicitly allow modeling
unavailable actions, e.g., we can model that a door can only be opened
when close enough to the door.} as $\EnAct(s) \eqdef \{ \act \mid
P(s,\act) \neq \bot \}$. States without available actions, i.e.,
states with $\EnAct(s) = \emptyset$ are called \emph{terminal states}.
The \emph{successor states} of a state $s$ and an (enabled) action $\act$ is the
set of states that are reached from $s$ within one step with a positive
transition probability, i.e., $\Succ(s,\act) \eqdef \{ s' \mid
P(s,\act)(s')>0 \}$, and $\Succ(s) \eqdef\bigcup_{\act \in \EnAct(s)}
\Succ(s,\act)$.
```

```node
# \taxon{example}
We introduce a six-state toy-example (\ref{fig:toysg}) to illustrate the
definitions. Terminal states are drawn with a rectangle, $\pOne$-states with a
circle and $\pTwo$-states with a diamond. For every state $s$ and action $\act$,
we draw transitions in the form of edges that connect all successors $s'$, and
label them with the associated probabilities $P(s,\act)(s')$. For conciseness,
we omit labelling probability $1$ transitions.
```

```custom[tikzfig] \label{fig:toysg}
\caption{A running example.}
\begin{tikzpicture}
  \node[sstate,initial,initial text=] (s0) {$s_0$};
  \node[astate,right=of s0] (s1) {$s_1$};
  \node[astate,below=of s0] (s2) {$s_2$};

  \node[sstate,below=of s1] (s3) {$s_3$};

  \node[tstate,right=1.4cm of s1] (target) {$\target$};
  \node[tstate,right=1.4cm of s3] (sink) {$\sink$};

  \node[actnode,right=4mm of s1] (a1) {};
  \node[actnode,right=4mm of s3] (a2a) {};


  \draw[->] (s0) -- node[actnode] {}
                    node[near start,auto,elab] {$a$} (s1);
  \draw[->] (s0) -- node[actnode] {}
            node[near start,elab,right] {$b$} (s2);

  \draw[->] (s2) -- node[actnode] {}
            node[near start,elab,above] {$a$} (s3);

  \draw[->] (s1) -- node[actnode] {}
            node[near start,elab] {$b$}  (s3);
  \draw[->] (s1) -- node[elab] {$a$} (a1);
  \draw[->] (a1) -- node[elab] {$\tfrac{1}{3}$} (target);
  \draw[->] (a1) -- node[elab,near start,left] {$\tfrac{2}{3}$} (sink);
  \draw[->] (a2a) -- node[elab,near start,xshift=0.1cm] {$\tfrac{1}{3}$} (target);
  \draw[->] (a2a) -- node[elab,pos=0.6,above] {$\tfrac{2}{3}$} (sink);
  \draw[->] (s3) -- node[elab] {$a$} (a2a);
  \draw[->] (s3) edge[bend right=30] node[actnode] {}
                    node[near start,below] {$b$} (sink);


\end{tikzpicture}
```

```node
# \taxon{remark}
SGs capture a variety of models. For example, if $|\EnAct(s)| = 1$ for all
uncontrolled states, $s \in S_\pTwo$, then $\sg$ is a \emph{Markov decision
process} (MDP). If $|\EnAct(s)| = 1$ for all $s \in S$, then $\sg$ is a
\emph{Markov chain}. If $P(s,\act)$ is a Dirac distribution for every $s \in S$
and $\act \in \Act$, then $\sg$ is called \emph{deterministic} or a
\emph{2-player game}.
```

```node
# \taxon{remark}
Paths are defined just like in MDPs, except that that $\pOne$ states are even
indexed and $\pTwo$ states are odd indexed - as we assume alternation.
Additionally, it is helpful to partition paths based on their last state:
$\POnePaths = \{ \path \in \Paths \mid \last(\path) \in S_\pOne \}$ and
$\PTwoPaths = \Paths \setminus \POnePaths$.
```

```node
# \taxon{example}
In \ref{fig:toysg}, there are two paths that end in $s_3$, $s_0 \xrightarrow{a}
s_1 \xrightarrow{b} s_3$ and $s_0 \xrightarrow{b} s_2 \xrightarrow{a} s_3$, both
of length $2$. Both paths are in $\POnePaths$, as $s_3 \in S_\pOne$.
```

### Policies and Schedules {#sec:oaRE}

Whenever some state $s$ is reached, the corresponding player draws an action from
$\EnAct(s)$. As standard, we capture this with the notion of a
scheduler.\sidenote{Also known as \emph{strategy} or \emph{policy}.} A
\emph{scheduler} is a tuple of \emph{player policies} $\sched = \langle
\sched_\pOne, \sched_\pTwo \rangle$ with $\sched_{\player} \colon \PlayerPaths
\rightarrow \Distr(\Act)$ such that $\supp(\sched_i(\path)) \subseteq
\EnAct(\last(\path))$ for each $\path$, i.e., for every history, the policy sets
a distribution over the enabled successor actions. For a given path, $\path$ and
a policy $\sched_{\player}$, we denote by $\sched_{\player}(\act~|~\path)$ the
distribution of actions induced by $\sched_{\player}$ given the path $\path$. To
ease notation, we liberally use the notation $\sched \colon \Paths \rightarrow
\Distr(\Act)$, where this function is given dependent on which player owns the
last state.

```node
# \taxon{example}
An example for a $\pOne$-policy $\pOneSched$ is given by,

$$\pOneSched(\alpha~|~\xi) =
\begin{cases}
  \tfrac{1}{2} & \text{if } \alpha \in \{ a,b \}, ~\xi = s_0,\\
  1 & \text{if } \alpha = a,~\xi = s_0\xrightarrow{b}s_2 \xrightarrow{a} s_3,\\
  1 & \text{if } \alpha = b,~\xi = s_0\xrightarrow{a}s_1\xrightarrow{b}s_3.
\end{cases}$$
```

The probability $\Pr(\path \mid \sched)$ of a finite path $\path$ in an SG $\sg$
conditioned on a policy $\sched$ is given by the product of the transition
probabilities along a path. More precisely, we define the probability $\Pr(\path
\mid \sched)$ recursively as:

$$\begin{aligned}
  \Pr(s \mid \sched) &\eqdef 1\\
  \Pr(\path~|~\sigma) &\eqdef \Pr(\path'\mid\sched)\cdot \sched(\act\mid\path') \cdot P(\last(\path'),\act)(s')
\end{aligned}$$

where $\path = \path' \xrightarrow{\act} s'$. Furthermore, just like with MDPs,
the probability of a prefix-free set $X \subseteq \Paths$ of paths is the sum
over the individual path probabilities, $\Pr(X \mid \sched) = \sum_{\path \in X}
\Pr(\path \mid \sched )$.

### Entropic Reactive Control Improvisation {#sec:bnUH}

Finally, to simplify our problem statement, we now define causal entropy of a
schedule in a stochastic game. Recall that a path alternates states and actions.
The next state after observing a sequence of state-action pairs is a random
variable. Formally, given $\sg$ and a scheduler $\sched$, let us denote by
$\RV{A}^{\pOne}_{1:i}$ and $\RV{S}_{1:i}$ random variable sequences for
$\pOne$-player actions and states respectively. The causal entropy of
controllable actions in $\tau$-length paths under $\sched$ is then,

$$H_\tau(\sigma) \eqdef H( \RV{A}^{\pOne}_{1:\tau'} \cmid \RV{S}_{1:\tau} ),$$

where $\tau' = \lceil \frac{\tau}{2}\rceil$ is the number of $\pOne$-actions due
to alternation.

```node
# \taxon{example}
Consider the uniform $\pOne$ policy on \ref{fig:toysg}. If $\sched_{\pTwo}(a\mid
\xi) = 1$. $H_\tau(\sigma) = \log(2) + \tfrac{1}{2}(\log(2))$. Note, only $\pOne$
can \emph{add} entropy, while $\pTwo$ and stochastic transitions yield convex
combinations via expectation.
```

We now formalize the problem statement.

```node
# The Entropic Control Improvisation (ERCI) Problem \taxon{problem} \label{prob:erci}
Given a SG $\sg$, $\tau$-bounded path properties $\hard$ and $\soft$, and thresholds $\scthreshold \in [0,1]$ and $\randomness \in [0,\infty)$, find a $\pOne$-policy $\pOneSched$ (or report that none exists) such that for every $\pTwo$-policy $\pTwoSched$,

1. (\emph{hard constraint}) $\Pr(\hard \mid \sched) \geq 1$
2. (\emph{soft constraint}) $\Pr(\soft \mid \sched) \geq \scthreshold$
3. (\emph{randomness constraint}) $H_\tau(\sigma) \geq \randomness$

where $\sched = \langle \pOneSched, \pTwoSched \rangle$.
```

We say that an instance of the ERCI problem is realizable, if an appropriate
$\pOneSched$ exists and call such $\pOneSched$ an \emph{improviser}. The problem
is unrealizable otherwise.

```node
# \taxon{remark}
The maximum causal entropy planners used in \ref{part:learn}{Part: Learning and Teaching}
correspond to the optimization variant of ERCI. As well shall see, our solution
to ERCI actually creates improvisers that maximized causal entropy subject to a
performance constraint (as desired).
```

## ERCI as multi-objective optimization {#sec:convex}

We investigate the ERCI problem statement. Based on a sequence of observations,
we reduce the ERCI problem to the Core ERCI problem which significantly eases the
description (and implementation) of the algorithm afterwards.

### Preprocessing {#sec:v19p}

To ease the technical exposition, we make the following assumptions (without
loss of generality): We assume the graph structure underlying the SG is finite
and acyclic -- and thus all paths are finite length. When considering
$\tau$-bounded path properties (monitorable by finite automata), this
assumption is naturally realized by a $\tau$-step unrolling of a monitor
augmented SG, i.e., augmenting the state space with a counter from $0$ to $\tau$
and the current property monitor state.

Next, in order to ensure the hard constraint, $\hard$, we calculate all states
from which the $\pTwo$-player can enforce violating the hard constraint. Such
states are identifiable using a single topologically ordered pass over $\sg$ from
the terminal states to the initial state. We remove such states along with their
in- and outgoing transitions. Any $\pOne$-policy now satisfies the hard
constraint. The remaining terminal states are all merged into two states
$\target$ and $\sink$, based on membership in $\soft$, i.e.,

$$\begin{aligned}
  \last(\path) = \target ~&\implies~ \path \in \soft\\
  \last(\path) = \sink ~&\implies~ \path \notin \soft
\end{aligned}$$

```node
# \taxon{example}
In \ref{fig:minimal:mdp} we show a (deterministic) MDP and we plot for all
schedulers the induced probability to reach $\target$ and the induced causal
entropy, in \ref{fig:minimal:soft} and \ref{fig:minimal:entropy}, respectively.
We see that taking action $a$ with increasing probability yields a larger
probability to reach $\target$, whereas taking action $a$ and $b$ uniformly at
random is optimal for the entropy.
```

```custom[tikzfig] \label{fig:minimal:mdp}
\caption{Minimal ERCI problem with $\varphi = ( \last(\xi) = \target )$: the minimal MDP.}
\begin{tikzpicture}
  \node[sstate,initial, initial text=] (si) {$s_0$};
  \node[tstate,above=0.6cm of si] (s0) {$\target$};
  \node[tstate,below=0.6cm of si] (s1) {$\sink$};
  \draw[->] (si) -- node[right] {$a$} (s0);
  \draw[->] (si) -- node[right] {$b$} (s1);

\end{tikzpicture}
```

```custom[tikzfig] \label{fig:minimal:soft}
\caption{Minimal ERCI problem with $\varphi = ( \last(\xi) = \target )$: the probability to reach $\target$.}
\begin{tikzpicture}[scale=2]
 \draw[->] (-0.05, 0) -- (1, 0) node[below]{$\sched(a \mid s_0 )$};
    \draw[->] (0, -0.05) -- (0, 0.8) node[above] {$\Pr( \varphi \mid \sched)$};
    %\draw[-,dashed] (0.4,0) -- (0.4,0.5184);
    %\draw[-,dashed] (0.0,0.5184) -- (0.4,0.5184);
  \draw[ domain=0:0.8, smooth, variable=\x, blue] plot ({\x}, {\x});
\end{tikzpicture}
```

```custom[tikzfig] \label{fig:minimal:entropy}
\caption{Minimal ERCI problem with $\varphi = ( \last(\xi) = \target )$: the causal entropy.}
\begin{tikzpicture}[scale=2]
 \draw[->] (-0.05, 0) -- (1, 0) node[below]{$\sched(a \mid s_0 )$};
    \draw[->] (0, -0.05) -- (0, 0.8) node[above] {$H(\sched)$};
    %\draw[-,dashed] (0.4,0) -- (0.4,0.5184);
    %\draw[-,dashed] (0.0,0.5184) -- (0.4,0.5184);
  \draw[ domain=0.001:0.999, smooth, variable=\x, blue] plot ({\x}, {-\x * ln(\x) - (1 - \x)*  ln(1-\x)});
\end{tikzpicture}
```

### Geometric Perspective {#sec:ZJmt}

There is a natural trade-off between probability of generating paths in $\varphi$
(from here onwards: \emph{the performance}) and causal entropy induced by a
policy (\emph{the randomization}). In particular, with all other ingredients
fixed, we are interested in understanding the combinations of $\scthreshold$ and
$\randomness$ that yield a solvable instance of the (core) ERCI problem. To this
end, we cast ERCI as an instance of a multi-objective optimization problem, and
study its Pareto front. Some ideas are inspired by variants of multi-objective
analysis of MDPs with multiple soft constraints,
e.g. \cite{DBLP:conf/stacs/ChatterjeeMH06,DBLP:conf/tacas/EtessamiKVY07,DBLP:conf/atva/ForejtKP12}.

```custom[tikzfig] \label{fig:geom:guarantee}
\caption{Geometric interpretation of the ERCI problem for some fixed SG: guaranteed points $\solutions_\pOneSched$.}
imgs/geom_guarantee.tex
```

```custom[tikzfig] \label{fig:geom:solution}
\caption{Geometric interpretation of the ERCI problem for some fixed SG: solutions $\solutions$.}
imgs/geom_solution.tex
```

```custom[tikzfig] \label{fig:geom:iterative}
\caption{Geometric interpretation of the ERCI problem for some fixed SG: iterative construction.}
imgs/geom_iterative.tex
```

```custom[tikzfig] \label{fig:geom:regret}
\caption{Geometric interpretation of the ERCI problem for some fixed SG: regret-based ERCI.}
imgs/geom_regret.tex
```

```custom[tikzfig] \label{fig:geom:doubling}
\caption{Geometric interpretation of the ERCI problem for some fixed SG: the rationality-based algorithm.}
imgs/geom_doubling.tex
```

It is convenient to consider this front geometrically. To begin, given a fixed
ERCI instance, a scheduler $\sched$ \emph{induces} a point $x_\sched$:

$$x_\sched \eqdef \Big\langle \Pr(X_\varphi \mid \sched), H(\sched) \Big\rangle \in [0,1] \times [0,\infty).$$

To ease notation, for $x_\sched = \langle \scp,\rndp \rangle$ we use $\scp_\sched
\eqdef \scp$ and $\rndp_\sched \eqdef \rndp$. Next, we partially order these
points via the standard product ordering:

$$\langle \scp,\rndp \rangle \preceq \langle \scp',\rndp' \rangle \quad\text{ iff }\quad \scp \leq \scp' \wedge \rndp \leq \rndp'.$$

We say that $\pOneSched$ \emph{guarantees} a point $x_\pOne \eqdef \langle \scp,
\rndp \rangle$, if for every policy $\pTwoSched$, using $\sched = \langle
\pOneSched, \pTwoSched \rangle$, we have $\scp_\sched \geq \scp$ and
$\rndp_\sched \geq \rndp$. Thus, a point is guaranteed if no matter what policy
$\pTwo$ uses, $x_\sched$ will induce a point no worse w.r.t. to either
randomization or performance than $x_\pOne$. We define \emph{the set of
guaranteed points} for a scheduler $\pOneSched$:

$$\solutions[\pOneSched] \eqdef \{ \langle \scp, \rndp \rangle \mid  \pOneSched \text{ guarantees } \langle \scp, \rndp \rangle \}.$$

We observe that guaranteed points are downward closed, i.e., if $\pOneSched$
guarantees $x$ and $x' \preceq x$, then $\pOneSched$ guarantees $x'$.

```node
# \taxon{example}
Consider \ref{fig:geom:guarantee}. We fix $\pOneSched$ and in the blue hatched
area draw all points induced by $\sched = \langle \pOneSched, \pTwoSched
\rangle$ when varying $\pTwoSched$. We take the minimal randomness $\rndp$ and
the minimal performance $\scp$. The points in the downward closure of $\langle
\scp, \rndp \rangle$ (green circle) are the guaranteed points for $\pOneSched$ in
the green solid area. We notice the gap between both areas: While the
performance and randomization may be better than the optimum that $\pOne$ can
guarantee, it cannot guarantee a higher randomization \emph{and} performance
simultaneously, as the $\pTwo$-player would have a counter-policy violating
either the performance \emph{or} the randomization.
```

Points guaranteed by some $\pOneSched$ are called \emph{achievable}. Thus, the
achievable points are: $\solutions = \bigcup_{\pOneSched}
\solutions[\pOneSched]$. Importantly, the ERCI problem is realizable iff $\langle
\scthreshold, \randomness \rangle$ is achievable. Thus, to solve ERCI instances,
we start by characterizing $\solutions$. We start by observing the $\solutions$
is convex\sidenote{That is, $x, x' \in \solutions$ implies for every $w \in
[0,1]$ that $w \cdot x + (1-w) \cdot x \in \solutions$.} (proof in
\ref{sec:proofs_erci}).

```node
# \taxon{proposition} \label{prop:convex}
The set of achievable points, $\solutions$, is convex.
```

Next, because $\solutions$ is downward closed, it suffices to study the
"maximal" or non-dominated points. Precisely, we say that a point $x$ is
\emph{dominated} by $x'$ if $x \prec x'$, i.e., if $x \preceq x' \wedge x \neq
x'$. The Pareto front $\pareto{\solutions}$ of $\solutions$ is then the set of
non-dominated achievable points,

$$\pareto{\solutions} \eqdef \{ x \in \solutions \mid \forall x' \in \solutions, x \not\prec x'  \}.$$

```node
# \taxon{observation} \label{obs:erci-pareto}
Importantly, it holds that the ERCI problem is satisfiable iff there exists a $x \in \pareto{\solutions}$ such that $\langle \scthreshold, \randomness \rangle \preceq x$.
```

```node
# \taxon{example}
The set $\solutions$ illustrated in \ref{fig:geom:solution} is obtained by taking
the union of guaranteed points, and can be characterized by the set of points on
the Pareto front: This is the curved border between the green and white area, in
particular the three green dots are on the Pareto front. Any ERCI instance with
$\langle \scthreshold, \randomness \rangle$ in the green area is realizable.
```

Approximating the Pareto front gives a natural approximation scheme for ERCI
instances: For any subset $\pareto{} \subseteq \pareto{\solutions}$,

1. If there exists an $x \in \pareto{}$ such that $\langle \scthreshold, \randomness \rangle \preceq x$, then the ERCI problem must be realizable and $x$ is a witness to realizability.
2. If there exists an $x \in \pareto{}$ such that $x \prec \langle \scthreshold, \randomness \rangle$, then the ERCI problem is not realizable and $x$ is a witness to unrealizability.

Due to convexity, we may speed up the search for realizability: If there exist
$x_1, x_2 \in \pareto{}$ such that $\langle \scthreshold, \randomness \rangle
\prec \big(w \cdot x_1 + (1-w) \cdot x_2\big)$, we call $x_1,x_2$ a witness-pair.

```node
# \taxon{remark}
Given a witness (pair) to realizability, it is easy to extract the corresponding
improviser. Let $x_1,x_2$ be a witness-pair to realizability, induced by
$\sched_{\rat_1}$ and $\sched_{\rat_2}$ such that $\langle\scthreshold,
\randomness\rangle\preceq w\cdot x_1 + (1-w)\cdot x_2$, then the policy
described by

$$\sigma^*_\pOne(\act \mid s) \eqdef w\cdot \sched_{\rat_1}(\act \mid s) + (1-w) \cdot \sched_{\rat_2}(\act  \mid s)$$

is an improviser solving the ERCI problem.
```

```node
# \taxon{example} \label{ex:approximation}
Consider \ref{fig:geom:iterative}. We have found three points on the Pareto
front, and already have a good impression of the trade-off between randomization
and performance. In particular, the green area is definitively a subset of
$\solutions$: It exploits the downward closure and the convexity of $\solutions$.
The red (dotted) parts contain the points on the Pareto front in their downward
closure, thus they cannot be part of the Pareto front themselves. Furthermore,
the topmost point on the Pareto front was obtained by maximizing performance (and
optimizing randomization only as a secondary objective). Thus, by construction,
the bricked area at the top is not realizable. Analogously, the bricked area at
the right reflects non-achievable randomization.
```

```node
# \taxon{remark} \label{rem:scalarwitnesses}
We notice that the multi-objective optimization perspective allows us to extend
the set of witnesses for unrealizability. In particular, every point of the
Pareto-curve can be described as optimizing some scalarization of the objectives.
Geometrically, it optimizes along a particular direction. Whenever we know that a
Pareto-optimal point $x = \langle \scp, \rndp \rangle$ optimizes a weighted
objective with weights $w = \langle w_1, w_2 \rangle$, then $x$ and $w$
\emph{together} are a witness for unrealizability for $\langle \scthreshold,
\randomness \rangle$ whenever $w_1 \cdot \scp + w_2 \cdot \rndp < w_1 \cdot
\scthreshold + w_2 \cdot \randomness$.
```

Thus a key algorithmic question in ERCI is how to efficiently explore the Pareto
front $\pareto{\solutions}$.

### Regret-Based ERCI {#sec:Rcei}

To algorithmically explore the Pareto-curve, we re-parameterize the ERCI problem.
First, we find the two special points induced by (1) optimizing performance and
only then randomization (the topmost green point in the figures) and (2)
optimizing randomization and only then performance (the rightmost green point).
As we have seen, these restrict the domain in which we can actually trade
performance for randomness. We define $\rndopt \eqdef \max \{ \rndp \mid \exists
\scp \text{ s.t. } \langle \scp, \rndp \rangle \in \solutions \}$, i.e., the
largest randomness that can be guaranteed by any $\pOne$-policy. Likewise, we
define $\scopt \eqdef \max \{ \scp \mid \exists \rndp \text{ s.t. } \langle \scp,
\rndp \rangle \in \solutions \}$, i.e., the largest performance that can be
guaranteed by any $\pOne$-policy. Then, we define $\scmin \eqdef \max \{ \scp
\mid \langle \scp, \rndopt \rangle \in \solutions \}$, the best performance that
$\pOne$ can guarantee while guaranteeing optimal randomness. Likewise, we define
the analogous $\rndmin \eqdef \max \{ \rndp \mid \langle \scopt, \rndp \rangle
\in \solutions \}$. We thus obtain two points on the Pareto front: $\langle
\scmin, \rndopt \rangle$ and $\langle \scopt, \rndmin \rangle$, and intuitively,
we can trade between these two points following the Pareto front.

Now, rather that fixing $\scthreshold$ and $\randomness$ a priori, we seek to
guarantee some percentage of the independently achievable soft constraint and
causal entropy measure. We re-parameterize ERCI as follows:

$$\scthreshold_\epsilon \eqdef \epsilon \cdot (\scopt - \scmin) + \scmin
\qquad
\randomness_\delta \eqdef \delta \cdot (\rndopt - \rndmin) + \rndmin$$

where $\epsilon, \delta \in [0, 1]$. We call this version of ERCI
\emph{regret-based}. We remark that the reparameterization is not only beneficial
from a usability point-of-view, but it also eases our exposition. Geometrically,
after computing $\scopt$ and $\rndopt$, we know that the left triangle in
\ref{fig:geom:regret} is definitively realizable, and the regret-based ERCI asks
whether the white circle is also realizable (where the point of the white point
is given by $\epsilon$ and $\delta$). Together, we obtain the following (core)
ERCI problem.

```node
# The Core ERCI Problem \taxon{problem} \label{prob:core-erci}
Given an finite acyclic SG $\sg$, with terminal states, $\target$ and $\sink$, and thresholds $\epsilon, \delta \in [0,1]$, find a $\pOne$-policy $\pOneSched$ s.t. for every $\pTwo$-policy $\pTwoSched$:

1. (\emph{soft constraint}) $\Pr(\last(\xi) = \target \mid \sched) \geq \scthreshold_\epsilon$
2. (\emph{randomness constraint}) $H(\sigma) \geq \randomness_\delta$

where $\sched = \langle \pOneSched, \pTwoSched \rangle$.
```

Finally, it is helpful to think about the Pareto front as a function of
randomization in this reparameterization. We define a characteristic function
which given a target performance ratio, $\epsilon$, yields the optimal randomness
ratio, $\delta$:

$$\begin{aligned}
  & \solfuncp\colon [0,1] \rightarrow [0, 1]    \\
  & \solfuncp(\delta) = \max_\epsilon \{ \randomness_\delta \mid \langle
  \scthreshold_\epsilon, \randomness_\delta \rangle \in \solutions \}
\end{aligned}$$

```node
# \taxon{proposition} \label{prop:erci:monotone}
$\solfuncp$ is continuous and (strictly) decreasing.
```

We shall temporarily postpone the proof of \ref{prop:erci:monotone}. For now, one
can observe that (non-strict) monotone decreasing follows directly from convexity
and using the adequate domains. Finally, the set $\solutions$ is (in general)
\emph{not} a finite polytope -- the MDP in \ref{fig:minimal:mdp} serves as an
example. Nevertheless, $\solutions$ can be well approximated with finitely many
vertices, see \ref{ex:approximation}. With these facts, we are now well-equipped
to develop the algorithms in \ref{sec:mdps} for MDPs and \ref{sec:erci-sgs} for
SGs.

## The Control Improvisation Problem for MDPs {#sec:mdps}

We present an algorithm for the control improvisation problem for MDPs, which in
the next section, will serve as a subroutine for an algorithm on SGs. Our goal
shall be to instantiate the approximation scheme from the previous section. In
particular, we seek to find points on the Pareto curve $\pareto{\solutions}$ and
incrementally build up $\pareto{} \subseteq \pareto{\solutions}$.

### Rationality {#sec:IC4F}

To start, recall that an MDP is a stochastic game with no action choices for the
environment, i.e., the environment is purely stochastic and the only degree of
freedom is $\pOne$'s policy. The key idea for finding points on the Pareto-curve
is to rephrase the trade-off between randomization and performance as a degree in
rationality $\rat$ of the policy. Formally, the rationality corresponds to the
following scalarization of our multi-objective
problem \cite{DBLP:journals/corr/abs-1805-00909},

```math \label{eq:scalarization}
J_\rat(\sched) \eqdef \Big\langle 1, \rat\Big\rangle \cdot \Big\langle\rndp_\sched, \scp_\sched\Big\rangle.
```

As we discussed in \ref{ch:dyn-prelim}{Workspaces and Decision Processes}, for
MDPs, the \strong{unique} ($\pOne$-)policy that optimizes \ref{eq:scalarization}
is given by a smooth variant of the Bellman equations \cite{mceThesis}, i.e., for
each rationality $\rat \in [0, \infty)$, we define a policy $\sched_\rat$ -- using
$s = \last(\path)$ -- as follows:

```math \label{eq:mdp-smooth-bellman}
\begin{aligned}
  &\sched_\rat(\act \mid s) \eqdef \exp( Q_\rat(s,\act) - V_\rat(s)) \\
  & V_\rat(s) \eqdef  \begin{cases}
    \lambda  \cdot \indicator{s = \target} & \text{if }s \in \{ \target, \sink \},\\
    \smoothmax_{\act \in \EnAct(s)}{  Q_\rat(s,\act) } & \text{otherwise.}
  \end{cases}\\
  & Q_\rat(s, \act) \eqdef \sum_{s'} P(s,\act,s') \cdot V_\rat(s').
\end{aligned}
```

```node
# \taxon{remark}
As opposed to the smooth Bellman backup of the previous chapters, here we have
written the backup in its more traditional $Q$ and $V$ decomposition. This is to
emphasize that the value is a function of the state (or state distribution)
indexed by the prefix, $\trc$.
```

To ease notation, we denote $x_\rat \eqdef x_{\sched_\rat}, \scp_\rat \eqdef
\scp_{\sched_\rat}, \rndp_\rat \eqdef \rndp_{\sched_\rat}$. Intuitively, as $\rat
\rightarrow 0$, $\sched_\rat$ approaches the uniform distribution over
\emph{all available actions}. Note that this policy maximizes (causal) entropy,
and thus $\rndopt = \rndp_0$. As $\lambda \rightarrow \infty$, this variant of the
Bellman equations coincides with the standard Bellman
equations \cite{DBLP:books/wi/Puterman94}, where $\sched_\rat$ selects
(uniformly) from actions \emph{that maximize performance}. Furthermore, the
monotonicity and smoothness of the above Bellman equations yields the following
proposition.

```node
# \taxon{proposition}
$\scp_\rat$ is continuously (and strictly) increasing in $\rat$ and $\rndp_\rat$ is smoothly (and strictly) decreasing in $\rat$.
```

In terms of $\solfuncp$, we can define:

$$\epsilon_\rat \eqdef \frac{\scp_\rat - \scp_0}{\scp_\infty} + \scp_0
\qquad\text{and}\qquad
\delta_\rat \eqdef \frac{\rndp_\rat - \rndp_\infty}{\rndp_0} + \rndp_{\infty}.$$

Then, because $\sched_\rat$ maximizes randomness given a target performance, one
derives:

$$\solfuncp\left(\delta_\rat\right) = \epsilon_\rat.$$

What remains is to instantiate the approximation scheme for the Pareto front by
varying the optimization direction $\langle \rat, 1\rangle$.\sidenote{Assuming
$\scopt, \rndopt \neq 0$ (which would otherwise yield trivial $\solutions$ and
$\pareto{\solutions}$).} In particular, we construct $\pareto{} = \{ x_\rat \mid
\rat \in \{ \rat_1, \rat_2, \ldots \} \}$ until $\pareto{}$ contains a witness to
either realizability or unrealizability of the ERCI instance. We notice that the
scalarization in \ref{eq:scalarization} means that we may additionally exploit
witnesses to unrealizability as outlined in \ref{rem:scalarwitnesses}. In the
remainder of this section, we improve upon randomly selecting values for $\rat$.

### Targeted Pareto-exploration {#sec:frdh}

The key ingredient to improve upon arbitrarily selecting $\rat_1, \ldots \rat_i$
is to exploit additional structure of the rationality. We propose a three staged
sequence: (i) Compute $x_\rat$ for the end points $\rat \in \{0, \infty\}$. (ii)
Double $\rat$ (starting at $\lambda=1$) until $h_\rat \leq \randomness$, yielding
$\rat_1\ldots \rat_j$. (iii) Binary search for $\rat \in [\rat_{j-1}, \rat_{j}]$.
We illustrate the idea in \ref{fig:geom:doubling}.

The algorithm terminates almost surely, that is: the algorithm halts if $\langle
\scthreshold, \randomness \rangle$ is not on $\pareto{\solutions}$ (or if we
happen to exactly hit $\langle \scthreshold, \randomness\rangle$ by selecting some
rationality $\rat$). As the Pareto front has measure 0, we argue that not halting
is thus merely a technical concern, as a small perturbation to the ERCI instance
(i.e. a \emph{smoothed analysis} \cite{SmoothedAnalysis}) on $\sg$ admits
decidability.

```node
# \taxon{observation} \label{obs:semi-decision}
Our approximation scheme yields a semi-decision process which halts iff either (a) $\langle \scthreshold, \randomness \rangle$ is bounded away from $\pareto{\solutions}$ \emph{or} (b) $\langle \scthreshold, \randomness \rangle$ is dominated by $x_{\rat_i}$.
```

Next, observe that if we terminate the binary search when the search region is
smaller than $\Delta$, this approximation scheme becomes linear in the MDP size
and logarithmic in the final rationality, $\rat_*$, and the resolution, $\Delta$,
i.e., the run-time is,

$$\mathcal{O}\Big(\underbrace{|\sg|}_{\text{Evaluate } x_\rat}\cdot\overbrace{\log(\rat_*)}^{\text{Doubling Phase}}\cdot\underbrace{\log(\tfrac{1}{\Delta})}_{\text{Binary Search}}\Big)$$

Finally, before generalizing to stochastic games, we observe that in practice,
$\rat = 100$ yields a nearly optimal policy, and thus one can often assume
$\rat_* \leq 100$ in our run-time analysis.

## The Control Improvisation Problem for SGs {#sec:erci-sgs}

MDP algorithm in hand, we are now ready to provide an algorithm for stochastic
games.

### Environment Policies {#sec:65oL}

We begin with three observations about the $\pTwo$-policies. First, for ERCI, we
can assume an adversary for $\pTwo$ that aims to foil $\pOne$ achieving both the
performance \emph{and} randomization requirement. We call such a $\pTwo$-policy
\emph{violating.} For a policy to be violating, it suffices to violate, against
every $\pOne$-policy independently, either performance \emph{or} randomization.
Second, if there is a violating $\pTwo$-policy, there is a deterministic
$\pTwo$-policy that proves this. In particular, at every state, $\pTwoSched$ may
choose to violate either constraint via the appropriate action with no incentive
to randomize. Third, fixing an environment policy reduces $\sg$ to a MDP
$\sg[\pTwoSched]$.

```custom[tikzfig] \label{fig:sg:simplest}
\caption{SG to illustrate entropy matching policies.}
imgs/sg_vis.tex
```

### A Sufficient Class of Policies {#sec:dAl7}

For MDPs, we have seen that varying rationality is sufficient to explore the
Pareto curve. We show that we can adapt that idea to a class we call
\emph{entropy matching policies}, which may be indexed by the (initial)
rationality. In the initial state, we start by assuming that $\pTwo$ selects a
(deterministic) policy, $\sched^\rat_\pTwo$, that lexicographically minimizes the
guaranteed randomness, followed by performance. On the sub-graph,
$\sg[\sched^\rat_\pTwo]$, $\pOne$ employs the corresponding entropy maximizing
policy for the MDP $\sg[\sched^\rat_\pTwo]$. Whenever $\pTwo$ diverges from the
entropy minimizing policy (to decrease the induced performance), we let $\pOne$
increase its rationality such that it still induces the same guaranteed
randomness. We refer to this idea as \emph{entropy matching}. The idea is that
the rationality at the initial state induces a worst-case entropy, and whatever
$\pTwo$ chooses to do, throughout the SG, we ensure that we indeed obtain this
entropy. The policy thus tracks this entropy and if necessary adapts the
rationality (which we call \emph{replanning}). Replanning ensures we obtain the
optimal performance from a particular point while still ensuring the required
randomness.

```node
# \taxon{example}
We sketch an entropy matching policy in \ref{fig:sg:simplest}. In particular, we
show part of a SG. For some fixed rationality $\rat$, we annotate in red, on the
left of the SG states, the entropy obtained when assuming that $\pTwo$ plays an
entropy-minimizing policy as outlined above. In particular, this means that in
$s_2$, $\pTwo$ selects action $a$. Now, our entropy-matching policy (in blue, on
the right) will play with rationality $\rat$, unless state $s_4$ is reached. As
this ensures a higher entropy, we may now select a higher rationality, $\rat'$.
```

### Soundness and Completeness {#sec:uIWb}

Importantly, observe that because fixing a policy for $\pOne$ yields a verifiable
point in $\solutions$, any witness for realizability we find is trivially sound.
For completeness, we can restrict ourselves to the case in which our algorithm
claims the ERCI instance unrealizable. Surprisingly, the class of policies we
consider suffices, and the algorithm is thus sound and (whenever halting)
complete (proof provided in \ref{sec:proofs_erci}). That is, all guaranteed
points are witnessed by an entropy matching policy!

Further, observe that as a corollary of the entropy matching family being
complete, it must be the case that $\solfuncp(\rndp_\rat)$ inherits continuity
and (strict) monotonicity from the MDP case. Namely, at each $\pTwo$ state, the
achievable points $\solutions$ are necessarily the intersection of the achievable
points of the sub-graphs. By induction, (with the MDP base case), we obtain
continuity and strict monotonicity.

### Algorithm: Memoizing Pareto Fronts {#sec:I23L}

We propose approximating the Pareto front using the same three staged sequence of
exploring rationality coefficients (at the initial state) as the MDP case: (1)
endpoints, (2) doubling, (3) binary search. To perform the these computations
efficiently, we adopt a geometric perspective. Observe that each node of $\sg$
indexes a sub-graph, which has a corresponding Pareto front for trading
performance for randomness. Further, note that the Pareto front at an $\pTwo$
node is the intersection of the Pareto fronts of its child nodes. Entropy
matching corresponds to "switching" between Pareto fronts and adjusting the
optimization direction by increasing the rationality. Thus, by traversing the
graph from the terminal states to the initial state, approximating Pareto fronts
along the way, one can memoize how to trade performance for randomness at any
given node. This preprocessing enables determining the minimum entropy response
for any optimization direction and quickly replanning via a convex combination of
Pareto optimal policies.

### Approximate Pareto Fronts {#sec:AZOs}

Of course, by varying $\rat$, one can only construct approximate Pareto fronts
$\hat{\pareto{}} \subseteq \pareto{\solutions}$. We propose the following
high-level algorithm to adapt the above algorithm to the case where each Pareto
front approximation introduces at most $\kappa$ error along the performance axis.

```node
# \taxon{procedure} \label{proc:approx-pareto}
1. Let $\tau$ denote the length of the longest path in $\sg$.
2. Let $0 < \kappa < 1$ be some arbitrary initial tolerance.
3. Recursively compute $\kappa$-close Pareto fronts for each successor state using replanning.
4. If the any minimum entropy action cannot be determined or $\scthreshold$ is within $\kappa\cdot \tau$ distance to (but outside of) $\hat{\pareto{}}$, halve $\kappa$ and repeat.
5. Otherwise, perform the entropy matching algorithm (with initial entropy $\randomness$) using these Pareto fronts and return the resulting policy (if on exists).
```

The soundness of this algorithm relies on the following critical facts: (1) Given
sufficient resolution, the minimum entropy $\pTwo$-actions can be determined. (2)
The resulting entropy depends solely on the resulting sub-graph (and is
independent of the current Pareto approximation). (3) Thus, when querying points
on $\pareto{\solutions}$, error can only accumulate for $\scp$. (4) Next, observe
that $\scp$ is computed using convex combinations of entropy matched points on
Pareto approximations. (5) Convex combinations of an error interval cannot
increase the error, i.e.,

$$q\cdot[x, x + \kappa] + \bar{q}\cdot[y, y + \kappa] = [z, z + \kappa],$$

where $z = q\cdot x + \bar{q}\cdot y$. Thus, so long as $\kappa\cdot\tau$ is enough
resolution to answer $\scp_\rat < \scthreshold$, one obtains a semi-decision
procedure as in the MDP case.

### Termination and Run Time {#sec:mQuZ}

First, as in the MDP case, the algorithm terminates almost surely, with the
exception occurring only for a subset of the Pareto front. Below, we give an
output-sensitive analysis of the run time (assuming it does halt). If $\kappa^*$
tolerance is required to terminate, then the $\kappa$ search introduces
$\mathcal{O}(\log(\tfrac{1}{\kappa^*}))$ iterations. Next, observe that each node
need process a given rationality coefficient at most once. Further, looking up
which pair of rationalities are need to upper and lower bound the performance for
a given randomness can be done in logarithmic time via binary search on
rationality coefficients. As the corresponding bounds and convex combinations can
be computed in constant time, this means this algorithm runs in time:

$$\mathcal{O}\Big(\log(\tfrac{1}{\kappa^*})\cdot N_\rat\cdot \log(N_\rat)\cdot |\sg|\Big),$$

where, $N_\rat$ is the number of unique rationality coefficients processed. If, as
in the MDP case, one assumes a maximum rationality coefficient $\rat^*$ and a
minimum rationality resolution $\Delta$, one obtains:

$$\mathcal{O}\Big(\underbrace{\log(\tfrac{1}{\kappa^*})}_{\kappa \text{ search}}\cdot \underbrace{\tfrac{\rat^*}{\Delta}\cdot \overbrace{\log(\tfrac{\rat^*}{\Delta})}^{\text{Replanning}}\cdot |\sg|}_{\text{Evaluate } \rat}\Big).$$

The above however is very conservative and empirically we observe $N_\rat$
bounded far away from $\tfrac{\rat^*}{\Delta}$.

```custom[latexfig] \label{fig:exp_times}
\caption{Plots to illustrate scalability: experimental times for computing Pareto front of a variety delivery drone problems.}
\scalebox{0.6}{\input{imgs/pareto_solve_time.pgf}}
```

```custom[latexfig] \label{fig:bdd_sizes}
\caption{Plots to illustrate scalability: BDD graph size as a function of horizon for the problems in our benchmark suite. Distribution of problems, non-uniform in horizon to avoid small horizon artifacts.}
\scalebox{0.62}{\input{imgs/bdd_size_by_horizon.pgf}}
```

## Implementation and Empirical Evaluation {#sec:empirical}

To experimentally validate the feasibility of our ERCI algorithm for SGs, we
implemented \cite{RSS21code} our algorithm in Python. The domain considered was
the same as our motivating example. Specifically, our experiments used a
$k\times k$ grid discretization of the workspace (cf. \ref{fig:motivating}), for
$k \in \{4,5,6,7\}$ where the four target houses lie in
$\{\lfloor\tfrac{k}{3}\rfloor, \lfloor\tfrac{2k}{3}\rfloor \}^2$, and the drones
$\droneEgo$ and $\droneEnv$ are initially at in the bottom left corner and top
right house resp. Furthermore, for simplicity, we embedded the avoid crash
condition as part of the soft constraint, rather than a hard
constraint.\sidenote{Note that counter-intuitively, only using soft constraints
generally results in harder instances as the compressed SGs are larger.} We took
$\pOne$'s dynamics to be deterministic and modeled $\pTwo$ as visiting each house
in either clock-wise or counter-wise order, where the orientation can switch with
(a potentially state dependent) probability $p \in [\tfrac{1}{100},
\tfrac{1}{50}]$ whenever a house is visited. Next, we considered an alternation
between $\pOne$ and $\pTwo$ to be a single logical time step, and (non-uniformly)
instantiate problem instances with horizons ranging from $6$ to $18$, i.e., paths
ranged from length $12$ to $36$. Finally, as we shall expand on in the next two
chapters, each SG was represented in a compressed form as a Binary Decision
Diagram (BDD) \cite{DBLP:journals/csur/Bryant92}.

### Results {#sec:jBaz}

First and foremost, we succeed in synthesizing controllers in the mentioned setup.
The controller randomizes its behavior while meeting the specification, which is
not surprising as the algorithm yields a correct-by-construction policy.

Next, we consider the practical run time of our algorithm. As \ref{fig:exp_times}
demonstrates, the empirical time to estimate the Pareto front seemed to increase
linearly with our SG encoding -- which is consistent with our complexity
analysis. Moreover, our encoding seems to linearly track with the horizon for all
$k$ (\ref{fig:bdd_sizes}), suggesting that the overall run time grows linearly in
the horizon within our parameterization. When combined with the potential to
parallelize across the rationality coefficients, these results suggest that
practical optimizations to our ERCI algorithm may admit usage on other more
complicated benchmarks. Finally, we remark that the use of a decision diagram
encoding did indeed dramatically decrease the size of the SG (with negligible
overhead).\sidenote{For example, the $(k=8,\text{horizon}=18)$ case is encoded
using a 505,100 node BDD ($|\sg| = 6,861$ nodes). Compare with the direct
encoding $|\sg| = |S|\cdot \tau \cdot |\text{monitor state}| = (8\times 8)^2
\cdot (2 \cdot 18) \cdot (2^4\cdot 2) \approx 37,000$.}

## Proofs {#sec:proofs_erci}

### Convexity of ERCI solution set {#sec:CSIM}

```node
# Proof Sketch of \ref{prop:convex} \taxon{proof} \label{proof:convex}
Recall that a set is convex, if it is closed under convex-combinations.\sidenote{That is, $x, x' \in \solutions$ implies for every $w \in [0,1]$ that $w \cdot x + (1-w) \cdot x \in \solutions$.} Consider two points $\langle \scp, \rndp \rangle, \langle \scp', \rndp' \rangle \in \solutions$ achieved by $\pOneSched$ and $\pOneSchedPrime$ respectively. Consider the new policy, $\pi$, defined by employing $\pOneSched$ with probability $q$ and $\pOneSchedPrime$ with probability $\bar{q} \eqdef 1 - q$. Because each policy \emph{guarantees} its corresponding performance, this new policy has performance at least $q\cdot \scp + \bar{q}\cdot \scp'$. Similarly, by viewing $\pi$ as a random variable and applying chain rule yields,

$$\begin{aligned}
  H_\tau(\sigma)
  \geq &~q \cdot H( \RV{A}^{\pOne}_{1:\tau'} \cmid \RV{S}_{1:\tau} \mid \pi=\pOneSched)~+\\
  &~\bar{q}  \cdot H( \RV{A}^{\pOne}_{1:\tau'} \cmid\RV{S}_{1:\tau} \mid \pi=\pOneSchedPrime)\\
  =&~q\cdot\rndp + \bar{q}\cdot \rndp'.
\end{aligned}$$

Thus, any convex combination of guaranteed points is guaranteed by a convex combination of the corresponding ego policies.
```

### Completeness of Entropy Matching for SGs {#sec:WmY7}

````node
# Proof Sketch of SG Completeness \taxon{proof} \label{proof:sg-completeness}
We prove the statement by induction over the (acyclic) SG. First, observe that on games with only terminal nodes, completeness follows directly. Next, suppose the entropy matching family is complete on all sub-graphs of $\sg$. To simplify our proof, observe that w.l.o.g., we can restrict our attention to ERCI instances on the Pareto front, $\langle \scthreshold,\randomness\rangle \in \pareto{\solutions}$. Next, for the sake of contradiction, we shall assume that no entropy matching policy achieves $\langle \scthreshold,\randomness\rangle$, but $\sched_{\pOne}^*$ does:

```math \label{eq:erci-incomplete}
\begin{aligned}
  &\forall \sched_\pOne \in \{\sched_{\pOne}^\rat\}_\rat~.~ x_{\sched_{\pOne}} \prec \langle \scthreshold, \randomness \rangle\\
  &\exists \sched_\pOne^* \notin \{\sched_{\pOne}^\rat\}_\rat~.~  \langle \scthreshold, \randomness \rangle \preceq x_{\sched_{\pOne}^*}.
\end{aligned}
```

Indeed, we may reformulate the second line of \ref{eq:erci-incomplete} to

```math \label{eq:erci-incomplete-eq}
\exists \sched_\pOne^* \notin \{\sched_{\pOne}^\rat\}_\rat~.~  \langle \scthreshold, \randomness \rangle = x_{\sched_{\pOne}^*}
```

as we assumed that $\langle \scthreshold, \randomness \rangle$ is Pareto-optimal.

Note that because the entropy matching family contains the maximizers and minimizers of entropy ($\rat = \infty$ and $\rat = 0$ resp.), and because increasing rationality monotonically decreases entropy, there must exist some rationality, $\rat$, such that $\sched_\pOne^\rat$ induces entropy $\randomness$:

$$\rndp_{\sched_\pOne^\rat} = \randomness = \rndp_{\sched_\pOne^*},$$

where the second equality follows from \ref{eq:erci-incomplete-eq}. Next, let $\sched_\pTwo^\rat$ denote the min-entropy $\pTwo$-policy given $\sched_\pOne^{\rat}$, i.e., the policy that minimizes entropy in $\sg[\sched_\pOne^{\rat}]$. Because $\sched_\pOne^*$ witnesses $\langle\scthreshold, \randomness\rangle$, it must be the case that:

$$\rndp_{\langle \sched_\pOne^*, \sched_\pTwo^\rat \rangle} \geq \randomness
\qquad \text{and} \qquad
\scp_{\langle \sched_\pOne^*, \sched_\pTwo^\rat\rangle} \geq \scthreshold$$

Recalling that for MDPs, the maximum entropy policies as defined in \ref{eq:mdp-smooth-bellman} are the unique maximizers of entropy (given $\scp$), it must be the case that:

$$\randomness = \rndp_{\langle \sched_\pOne^\rat \sched_\pTwo^\rat \rangle} \geq  \rndp_{\langle \sched_\pOne^*, \sched_\pTwo^\rat \rangle}\geq \randomness,$$

and thus,

$$\rndp_{\langle \sched_\pOne^\rat \sched_\pTwo^\rat \rangle} =  \rndp_{\langle \sched_\pOne^*, \sched_\pTwo^\rat \rangle}.$$

Thus, from uniqueness on MDPs, $\sched_\pOne^\rat$ and $\sched_\pOne^*$ must exactly match on $\sg[\sched_\pTwo^\rat]$ and must differ on some other subgraph. Applying the inductive hypothesis, we know that the entropy matching family is complete on these subgraphs, and thus if $\sched_\pOne^*$ achieves a given $\langle\scthreshold, \randomness\rangle$ on this subgraph, there must be an entropy matching that does so as well. Thus,

$$x_{\sched_{\pOne}^*} \preceq x_{\sched_{\rat^*}},$$

contradicting the assumptions in \ref{eq:erci-incomplete}. Thus, entropy matching must be complete.
````

## Bibliographic Notes {#sec:related}

### Control Improvisation in the Literature {#sec:lnFH}

In this section, we briefly compare ERCI with other forms of control
improvisation. Firstly, we observe that general Control Improvisation has been
proposed in stochastic environments for lane
changing \cite{DBLP:conf/cdc/GeM18} and imitating power usage in
households \cite{DBLP:conf/iotdi/AkkayaFVDLS16}. However, in those both settings,
the randomness constraint is phrased as an upper-bound on the probability of
indefinitely-long paths. Consequently, those randomness constraints are trivially
satisfied. In comparison, we consider the synthesis of policies that necessarily
randomize in presence of stochastic behavior in the environment. The closest
prior work is to ours is Reactive Control Improvisation (RCI) for (deterministic)
2-player games \cite{DBLP:conf/cav/FremontS18}. As in ERCI, RCI features three
kinds of constraints; hard, soft, and randomness. As in ERCI, RCI can be
preprocessed resulting in the following core problem.

```node
# The Core RCI Problem \taxon{problem} \label{prob:core-rci}
Given a finite acyclic (deterministic) SG $\sg$, with terminal states, $\target$ and $\sink$, and thresholds $\scthreshold \in (0,1)$ and $\randomness \in [0,\infty)$, find a $\pOne$-policy $\pOneSched$ such that for every $\pTwo$-policy $\pTwoSched$

1. (\emph{soft constraint}) $\Pr(\last(\xi) = \target \mid \sched) \geq \scthreshold$,
2. (\emph{randomness}) $\max_\xi{\Pr(\path \mid \sched)} \leq \ppthreshold$,

where $\sched = \langle \pOneSched, \pTwoSched \rangle$.
```

While RCI is only applied to deterministic SGs in
\cite{DBLP:conf/cav/FremontS18}, there is nothing in the definition that prevents
its application to the general class of SGs.\sidenote{However, this does not mean
that the algorithm to compute a solution carries over to the general case.} We
observe that then, the only difference between ERCI and RCI is that we use causal
entropy rather than an upper bound on the probability of a path to enforce
randomness. Below we address two problems with bounding the maximum probability
of a trace.

First, RCI fails to account for causality when measuring randomness. In
deterministic systems, for which RCI was conceived, this distinction is
unnecessary, but stochastic systems must deal with counter-factuals. In practice,
RCI encodes an agent model that is systematically overly optimistic regarding the
outcomes of dynamics transitions \cite{DBLP:journals/corr/abs-1805-00909}. This
results in policies with worse performance given a fixed randomness target. In
the context of our motivating drone example, applying RCI thus results in a
policy that is both quantitatively and qualitatively less random than the ERCI.

Second, RCI fails to enforce randomization if there exists \emph{any} path with
sufficiently high probability. The next (pathological) example illustrates.

```custom[tikzfig] \label{fig:drciOnSgs}
\caption{Example Illustrating the problem with RCI in stochastic environments.}
\begin{tikzpicture}
        \node[sstate, initial, initial text=] (s0) {$s_0$};
    \node[actnode,right=of s0, xshift=-2em] (e0) {};

  \node[sstate,right=of s0, yshift=2.5em] (s2) {$s_2$};
        \node[sstate,above=0.4cm of s2] (s1) {$s_1$};
  \node[below=0.1cm of s2] (sdots) {$\vdots$};
  \node[sstate,below=0.1cm of sdots] (sn) {$s_n$};

  \node[sstate,right=of s1] (t1) {$t_1$};
  \node[right=of t1] (tdots) {$\hdots$};
  \node[sstate,right=of tdots] (tn) {$t_m$};
  \node[sstate, right=2.2cm of e0] (u) {$u$};
  \node[sstate, right=of u, yshift=1em] (v1) {$v_1$};
  \node[sstate, right=of u, yshift=-1em] (v2) {$v_2$};
  \node[right=0.5cm of v1] {$\hdots$};
  \node[right=0.5cm of v2] {$\hdots$};



  \draw[->] (t1) -- node[elab] {$1$} (tdots);
  \draw[->] (tdots) -- node[elab] {$1$} (tn);

  \draw[->] (s0) -- node[elab] {} (e0);

  \draw[->] (e0) -- node[elab] {$\tfrac{1}{n}$} (s1);
  \draw[->] (e0) -- node[elab,below,xshift=1mm] {$\tfrac{1}{n}$} (s2);
  \draw[->] (e0) -- node[elab,below,xshift=-1mm] {$\tfrac{1}{n}$} (sn);

  \draw[->] (s1) -- node[elab,above] {$1$} (t1);
  \draw[->] (s2) -- node[elab,near end,above] {$1$} (u);
  \draw[->] (sn) -- node[elab,near end,below] {$1$} (u);

  \draw[->] (u) -- node[actnode] {} node[elab,above, near start] {$a$}  node[elab,above, near end] {$1$} (v1);
  \draw[->] (u) -- node[actnode] {} node[elab,below, near start] {$b$} node[elab,below, near end] {$1$} (v2);


\end{tikzpicture}
```

```node
# \taxon{example}
Consider the SG (actually, an MDP where we omit the $\pTwo$-states) in \ref{fig:drciOnSgs}. First consider that under each scheduler, the path from $s_0$ to $t_m$ has probability $\tfrac{1}{n}$. In particular, this means that a feasible RCI instance (applied to an SG) must have $\ppthreshold \geq \tfrac{1}{n}$. At the same time, every path in the SG already has probability at most $\tfrac{1}{n}$, and thus, every scheduler that satisfies the randomness constraint for $\delta = 1$ satisfies it for any $\ppthreshold \geq \tfrac{1}{n}$. Thus, for this MDP, the RCI formulation fails to enforce any randomization in the $\pOne$-policy. By contrast, a causal entropy constraint from ERCI will continuously trade-off randomness for performance.
```

On the other hand, one can observe that in reality, proposed algorithms for
solving RCI equally distribute probability mass across the maximum number of
paths that $\pOne$ can guarantee \cite{DBLP:conf/cav/FremontS18}. We remark that
because (1) causal entropy reduces to non-causal entropy in deterministic
dynamics and (2) uniform distributions maximize entropy, our proposed entropy
matching family exactly agrees with existing RCI algorithms on deterministic SGs.
Thus, we observe the following proposition.

```node
# \taxon{proposition} \label{prop:conservative}
There exists a computable function,

$$f \colon (\ppthreshold, \sg) \mapsto \randomness,$$

such that, for any deterministic SG, $\sg$, and performance threshold $\scthreshold$, there exists an $\pOne$-policy solving the RCI problem with threshold $\ppthreshold$ iff there exists a $\pOne$-policy solving the ERCI problem with threshold $\randomness = f(\ppthreshold, \sg)$.
```

### Additional Related Work {#sec:ckPL}

Synthesis in MDPs with multiple hard and soft constraints (often over indefinite
horizons) is a well-studied
problem \cite{DBLP:conf/stacs/ChatterjeeMH06,DBLP:conf/tacas/EtessamiKVY07,DBLP:conf/atva/ForejtKP12,DBLP:journals/fmsd/RandourRS17}.
In this setting, one generates deterministic policies and their convex
combinations. Put differently, some degree of randomization is \emph{not an
objective}, but rather a consequence. Interestingly,
in \cite{DBLP:conf/tacas/DelgrangeKQR20} the optimal policies in \emph{absence}
of randomization are investigated. Along similar
lines, \cite{DBLP:journals/jcss/BrazdilCFK17} trades average performance for less
variance, thereby implicitly trading off the average and the worst-case
performance. The original results sparked interest in different extension to MDPs
and the type of soft constraints, such as continuous
MDPs \cite{DBLP:journals/csysl/HaesaertNS21} and continuous-time
MDPs \cite{DBLP:conf/cav/QuatmannJK17}, cost-bounded
reachability \cite{DBLP:journals/jar/HartmannsJKQ20}, or mean-payoff
properties \cite{DBLP:journals/corr/abs-1104-3489}. The algorithms have also been
extended towards stochastic
games \cite{DBLP:conf/mfcs/ChenFKSW13,DBLP:journals/sttt/KwiatkowskaPW18}.
Finally, notions of lexicographic multi-objective
synthesis \cite{DBLP:conf/cav/ChatterjeeKWW20} -- in which one optimizes a
secondary criterion among all policies that are optimal with respect to a first
criterion bare some resemblance with the algorithm we consider. The
aforementioned algorithms have been put in a robotics context
in \cite{DBLP:journals/ijrr/LacerdaFPH19}. Finding policies that optimize reward
objectives is well-studied in the field of reinforcement learning, and has been
extended to generate Pareto fronts for multiple
objectives \cite{DBLP:conf/icml/NatarajanT05,DBLP:conf/adprl/ParisiPSBR14}.

Next, our core ERCI instance can be seen as a multi-objective path
problem \cite{DBLP:conf/icra/AmigoniG05,DBLP:journals/eswa/NazarahariKD19,DBLP:conf/icml/XuTMRSM20}.
The literature on multi-object path finding differs prominently from ERCI in two
aspects: they do not trade-off randomization and performance, and they do not
trade-off declarative and formal constraints with the accompanying formal
guarantees, but are more search-based.

Another related domain is the problem of (randomly) patrolling a perimeters and
points of
interest \cite{DBLP:conf/icra/AgmonKK08,DBLP:conf/icra/AmigoniBG09,DBLP:conf/iros/PortugalPRC14}.
Closest to our work are formalisms rooted in game-theory, such as
\emph{Stackelberg games} \cite{simaan1973stackelberg,DBLP:conf/atal/ParuchuriPTOK07}.
Stackelberg games have been extending to Stackelberg
planning \cite{DBLP:conf/aaai/SpeicherS00K18} in which a trade-off between the
cost for the defender and the attacker can be investigated. Most related are the
zero-sum \emph{patrolling games} introduced
in \cite{DBLP:journals/ior/AlpernMP11}, which has led to numerous practical
solutions \cite{DBLP:books/daglib/0040483}. Patrolling games are explicitly games
between an intruder and a defender, and there is no stochastic environment.
Adding additional objectives makes solving these problems harder
\cite{DBLP:conf/atal/Klaska0R20} and in general, the obtained policies are no
longer applicable. To overcome this, a specific set of fixed objectives has been
added to these games recently \cite{DBLP:conf/atal/Klaska0R20}. The large common
aspect in all of this work is that optimal strategies do randomize. As in the
synthesis work above, this is a consequence of the objectives rather than an
objective in itself. In comparison, we provide a general framework and in
particular support stochastic environments.

Finally, entropy as an optimization objective for MDPs with fixed rewards has
been well studied \cite{DBLP:journals/tac/SavasOCKT20}, particularly in the
context of regularizing (robustifying) inverse and reinforcement
learning \cite{mceThesis, DBLP:conf/icml/GeistSP19}. The primary distinction from
our work (in the MDP setting) is the unspecified (performance/entropy)
trade-off. Nevertheless, as previously discussed, the specification variant of
this literature served as the basis for our MDP
subroutine \cite{DBLP:conf/cav/Vazquez-Chanlatte20}. Beyond Markov models, the
(uniform) randomization over languages in finite
automata \cite{DBLP:journals/siamcomp/HickeyC83,DBLP:conf/soda/KannanSM95} or
over propositional
formulae \cite{DBLP:journals/tcs/JerrumVV86,DBLP:journals/iandc/BellareGP00,DBLP:conf/dac/ChakrabortyMV14}
has received quite some attention, however neither of those approaches support
the notion of soft constraints or the related trade-offs.
