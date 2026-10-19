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
$\LSE$ for log-sum-exp, $\softmax$ for the soft-argmax, $\Act$ for a set of actions,
and $\Distr(S)$ for the distributions over $S$.

\def\uniform{\operatorname{Uniform}}
\def\Reals{\mathbb{R}}
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
\bot\}$; a state with none is \strong{terminal} \cite{luce1959individual}.
