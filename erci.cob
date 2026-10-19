# Improvisation in Stochastic Games {#ch:erci}

This chapter introduces Entropic Reactive Control Improvisation (ERCI), a framework for
balancing performance and exploration in sequential decision-making problems.

```macros \label{def:erci-notation}
We write $\pOne$ for the ego player, $\pOneSched$ for the ego player's schedule,
$\rndp$ for a randomness level, $\randomness$ for a vector of them, $\scp$ for a
satisfaction probability, $\scthreshold$ for a vector of those, and $\solutions$
for a set of solutions. A star marks the optimum, and a minus sign the minimum.

\def\pOne{\mathsf{ego}}
\def\pOneSched{{\sigma_{\pOne}}}
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

## Contributions {#sec:Tvdi}

We make the following contributions:

- We formalize and generalize a notion of entropy-based control
  improvisation in MDPs and stochastic games.
- We provide a general algorithmic solution to the ERCI problem.
- We show how the ERCI framework relates to existing methods in
  control and reinforcement learning.
- We provide empirical results showing the effectiveness of ERCI
  in several domains.

## Overview {#sec:SXcM}

ERCI is a general framework for balancing performance and exploration. It is
particularly useful in settings where we want to avoid overly conservative
policies that fail to explore effectively, or overly aggressive policies that
fail to achieve high performance.

## Motivating Example {#sec:1efJ}

In this section, we present a simple example to illustrate the key ideas
of ERCI. 

```custom[tikzfig] \label{fig:motivating}
\begin{tikzpicture}[scale=1.5]
  \node[circle, draw=black, inner sep=1pt, minimum height=6mm] (s0) {$s_0$};
  \node[circle, right=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s1) {$s_1$};
  \node[circle, below=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s2) {$s_2$};
  \node[circle, below=2cm of s1, draw=black, inner sep=1pt, minimum height=6mm] (s3) {$s_3$};
  \draw[->] (s0) -- node[above] {$a$} (s1);
  \draw[->] (s0) -- node[left] {$b$} (s2);
  \draw[->] (s1) -- node[right] {$b$} (s3);
  \draw[->] (s2) -- node[below] {$a$} (s3);
\end{tikzpicture}
```

\emph{The motivation for ERCI.}
This example illustrates a simple MDP with four states and two actions, $a$ and $b$.
The goal is to find a policy that balances performance and exploration.

## Nondeterministic Model {#sec:Ht4m}

In the nondeterministic model, we consider a finite set of states $S$, a finite
set of actions $A$, and a transition function $\delta : S \times A \to 2^S$ that
maps a state and action to a set of possible next states.

## Stochastic Model {#sec:KiIx}

In the stochastic model, we consider a finite set of states $S$, a finite
set of actions $A$, and a transition function $P : S \times A \times S \to [0, 1]$
that maps a state, action, and next state to a probability of transition.

## Nondeterministic and Stochastic Model {#sec:Ewm0}

However, a natural generalization of the model combines both deterministic
and stochastic elements.

## ERCI as a unifying framework {#sec:ZnYc}

ERCI provides a unifying framework for control improvisation. In particular,
it provides a way to balance performance and exploration in a principled way.

## Problem Statement {#sec:E6a7}

This section formalizes the novel Entropic Reactive Control Improvisation
problem. We consider a stochastic game $\mathcal{G} = (S, A, P)$ where $S$ is a set
of states, $A$ is a set of actions, and $P$ is a transition probability function.

## Stochastic Games {#sec:79vO}

We define a stochastic game as a tuple $\mathcal{G} = (S, A, P)$ where $S$ is a set
of states, $A$ is a set of actions, and $P$ is a transition probability function.

## Entropic Reactive Control Improvisation {#sec:nEqW}

In this section, we formalize the problem of Entropic Reactive Control
Improvisation, which is a generalization of the problem of optimal control.

## Preprocessing {#sec:Wv2i}

In this section, we describe a preprocessing step that is used in the
entropic reactive control improvisation algorithm.

```custom[tikzfig] \label{fig:minimal:mdp}
\begin{tikzpicture}[scale=1.5]
  \node[circle, draw=black, inner sep=1pt, minimum height=6mm] (s0) {$s_0$};
  \node[circle, right=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s1) {$s_1$};
  \node[circle, below=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s2) {$s_2$};
  \node[circle, below=2cm of s1, draw=black, inner sep=1pt, minimum height=6mm] (s3) {$s_3$};
  \draw[->] (s0) -- node[above] {$a$} (s1);
  \draw[->] (s0) -- node[left] {$b$} (s2);
  \draw[->] (s1) -- node[right] {$b$} (s3);
  \draw[->] (s2) -- node[below] {$a$} (s3);
\end{tikzpicture}
```

```custom[tikzfig] \label{fig:minimal:soft}
\begin{tikzpicture}[scale=1.5]
  \node[circle, draw=black, inner sep=1pt, minimum height=6mm] (s0) {$s_0$};
  \node[circle, right=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s1) {$s_1$};
  \node[circle, below=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s2) {$s_2$};
  \node[circle, below=2cm of s1, draw=black, inner sep=1pt, minimum height=6mm] (s3) {$s_3$};
  \draw[->] (s0) -- node[above] {$a$} (s1);
  \draw[->] (s0) -- node[left] {$b$} (s2);
  \draw[->] (s1) -- node[right] {$b$} (s3);
  \draw[->] (s2) -- node[below] {$a$} (s3);
\end{tikzpicture}
```

```custom[tikzfig] \label{fig:minimal:entropy}
\begin{tikzpicture}[scale=1.5]
  \node[circle, draw=black, inner sep=1pt, minimum height=6mm] (s0) {$s_0$};
  \node[circle, right=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s1) {$s_1$};
  \node[circle, below=2cm of s0, draw=black, inner sep=1pt, minimum height=6mm] (s2) {$s_2$};
  \node[circle, below=2cm of s1, draw=black, inner sep=1pt, minimum height=6mm] (s3) {$s_3$};
  \draw[->] (s0) -- node[above] {$a$} (s1);
  \draw[->] (s0) -- node[left] {$b$} (s2);
  \draw[->] (s1) -- node[right] {$b$} (s3);
  \draw[->] (s2) -- node[below] {$a$} (s3);
\end{tikzpicture}
```

## Geometric Perspective {#sec:f8bD}

We can now study the geometric properties of the ERCI framework.

```custom[tikzfig] \label{fig:geometric}
imgs/geometric.tex
```

## Regret-Based ERCI {#sec:Fu8E}

In this section, we define a regret-based variant of ERCI that is based on
the concept of regret in reinforcement learning.

## The Control Improvisation Problem for MDPs {#sec:tak0}

In this section, we consider the control improvisation problem for MDPs.

## The Control Improvisation Problem for SGs {#sec:LQSI}

In this section, we consider the control improvisation problem for SGs.

```custom[tikzfig] \label{fig:sg:simplest}
imgs/sg_vis.tex
```

## A Sufficient Class of Policies {#sec:HCXF}

In this section, we define a sufficient class of policies for the ERCI framework.

## Soundness and Completeness {#sec:EHDd}

In this section, we prove the soundness and completeness of the ERCI framework.

## Algorithm: Memoizing Pareto Fronts {#sec:uB3X}

In this section, we present an algorithm for memoizing Pareto fronts.

## Approximate Pareto Fronts {#sec:5fUd}

In this section, we discuss approximate Pareto fronts.

## Termination and Run Time {#sec:G2b3}

In this section, we analyze the termination and run time of the ERCI algorithm.

## Implementation and Empirical Evaluation {#sec:4B9u}

In this section, we describe the implementation and empirical evaluation of the ERCI framework.

```custom[tikzfig] \label{fig:exp_times}
imgs/pareto_solve_time.pgf
```

```custom[tikzfig] \label{fig:bdd_sizes}
imgs/bdd_size_by_horizon.pgf
```

## Proofs {#sec:xeiv}

In this section, we provide the proofs for the main results.

## Bibliographic Notes {#sec:l2uZ}

In this section, we provide bibliographic notes for related work.

```custom[tikzfig] \label{fig:drciOnSgs}
\begin{tikzpicture}
  \node[sstate, initial, initial text=,initial where=left] (a1) {$s_0$}; 
  \node[right=of a1,color=blue] (a1r) {$\lambda$ }; 
  \draw[dotted,blue, thick] (a1) -- (a1r);
  \node[sstate,below=0.6cm of a1,xshift=8em] (a2) {$s_1$};
  \node[astate,below=0.6cm of a1,xshift=-8em] (a0) {$s_2$};
  \node[sstate,below=0.6cm of a0,xshift=-5em] (s1) {$s_3$};
  \node[sstate,below=0.6cm  of a0,xshift=7em] (s2) {$s_4$};
  \node[below=0.1cm of s1, inner sep=0.3pt] (x1) {};
  \node[below=0.1cm of s2, inner sep=0.3pt] (x2) {};
  \node[below=0.1cm of a2, inner sep=0.3pt] (x3) {};
  \draw[->] (a0) -- node[actnode] (x) {}
    node[pos=0.4,elab,right,xshift=2mm] {$a$}  (s1);
  \draw[->] (a0) -- node[actnode] {}
    node[pos=0.4,elab,left,xshift=-2mm] {$b$}  (s2);
  \draw[->] (a1) -- node[actnode] {}
    node[pos=0.4,elab,above,xshift=2mm] {$a$}  (a2);
  \draw[->] (a2) -- node[actnode] {}
    node[pos=0.4,elab,below,xshift=2mm] {$a$}  (s2);
  \draw[->] (s1) -- node[actnode] {}
    node[pos=0.4,elab,above,xshift=2mm] {$a$}  (s2);
\end{tikzpicture}
```

## Additional Related Work {#sec:dUY4}

In this section, we discuss additional related work in the field of control improvisation.