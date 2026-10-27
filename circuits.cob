# Stochastic Games as Circuits {#ch:circ}

> We demand rigidly defined areas of doubt and uncertainty!
>
> — Douglas Adams (The Hitchhiker's Guide to the Galaxy, 1979)

The previous chapter gave algorithms for control improvisation (maximum causal
entropy planning) in simple stochastic games. As the experiments and theory
showed, the run time of these algorithms scales linearly with the \strong{size}
of the game graph. In this chapter and the next, we develop a systematic way to
represent these game graphs in compressed form.

### Contributions {#sec:EoAP}

To succinctly represent a stochastic game for a history-dependent task
specification, we model probabilistic transition systems as circuits. The
result is a framework for answering queries about stochastic games, e.g., what
is the probability of satisfying a task specification when applying actions
uniformly at random, using tools such as Boolean Satisfiability (SAT) solvers
\cite{DBLP:journals/jacm/DavisP60} and Binary Decision Diagrams
\cite{DBLP:journals/csur/Bryant92}. The first step is to represent probabilistic
systems as sequential circuits. We begin by defining bit-vector predicates.

```macros \label{def:circuits-notation}
We write $\f$ for a Boolean predicate, $\Bool$ for the Boolean domain
$\{0, 1\}$, and $\BoolCube$ for the set of $n$-bit vectors. We write $\vx$,
$\vy$, $\vs$, and $\va$ for a bit-vector, an output vector, a state vector, and
an action vector. We write $\Prob$ for probability, and $\SampleBV$ for the
process of drawing $\vx$ from $n$ unbiased coin flips. We write $\tausim{\tau}$
for sampling the $\tau$-step unrolling of a sequential circuit, $\UNROLL$ for
the unrolling operator, and $\LAST$ for the function that keeps the last few
bits of a bit-vector.

\def\f{\varphi}
\def\Bool{\{0, 1\}}
\def\BoolCube{\{0, 1\}^n}
\def\Prob{\Pr}
\def\SampleBV{\mathclap{\vx \sim \BoolCube}}
\def\vx{\boldsymbol{x}}
\def\vy{\boldsymbol{y}}
\def\vs{\boldsymbol{s}}
\def\va{\boldsymbol{a}}
\def\UNROLL{U}
\def\LAST{\text{last}}
\def\tausim[t]{\mathrel{\overset{\scriptstyle{\t}}{\sim}}}
```

````node
# \taxon{definition} \label{def:bv_pred}
A \strong{bit-vector} is a string with alphabet $\{0, 1\}$. A \strong{$n$-ary
bit-vector predicate} maps $n$-bit vectors to $\Bool \subseteq \Reals$, e.g.,

```math \label{eq:bool_pred}
\f : \BoolCube \to \Bool.
```

If $\f(\vx) = 1$, we also call $\vx$ a \strong{model} of $\f$. We define the
\strong{model count} of $\f$, written $\#(\f)$, as the number of models of $\f$:

```math \label{eq:count}
\#(\f) \eqdef \sum_{\vx\in \BoolCube} \f(\vx).
```
````

```custom[latexfig] \label{fig:pred}
\caption{A $n$-ary bit-vector predicate as a circuit with $n$ inputs.}
imgs/circ.pdf_tex
```

Figure \ref{fig:pred} shows such a predicate. When the number of inputs of a
predicate $\f$ is clear, or does not matter, we write $\f(\vx)$ as a logical
sentence over $\vx$, where true maps to $1$ and false maps to $0$.

```node
# \taxon{example}
Let $\f : \Bool^{10} \to \Bool$ be the $10$-input map

$$\f(\vx) = x_1 \wedge x_7 \eqdef \begin{cases} 1 & \text{if } x_1 \wedge x_7\\ 0 & \text{otherwise} \end{cases}.$$

So $\f(\vx) = 1$ iff $x_1$ and $x_7$ are both true (both $1$). The other $8$
inputs are "don't care", each with two possible values, so $\#(\f) = 2^8$.
```

```node
# \taxon{example} \label{ex:lt_models}
Given $n \in \Nat$, let $k$ be an integer between $0$ and $2^n - 1$, and let
$\f : \Bool^n \to \Bool$ be given by

$$\f(\vx) = \vx < k,$$

where $\vx$ is read as an integer between $0$ and $2^n - 1$. Then $\#(\f) = k$,
since only $k$ unsigned integers are less than $k$.
```

A circuit becomes probabilistic once its inputs are the results of coin flips.
We introduce notation for drawing a bit-vector from $n$ unbiased coin flips.

````node
# \taxon{definition}
Write $x_1x_2\ldots x_n \sim \BoolCube$ for drawing an $n$-bit-vector by
flipping $n$ independent, unbiased coins:

```math \label{eq:random_bit_flip}
\Prob_{\SampleBV}(x_i = 0) = \Prob_{\SampleBV}(x_i = 1) = \frac{1}{2},
```

so the probability of drawing a particular bit-vector $\vx^*$ is

```math \label{eq:random_draw}
\Prob_{\SampleBV}(\vx = \vx^*) = \frac{1}{2^n}.
```
````

This gives an elementary observation about probabilistic statements.

````node
# \taxon{observation} \label{obs:1}
Given an $n$-ary bit-vector predicate $\f$, if one flips $n$ independent
unbiased coins, $\vx \sim \BoolCube$, the probability that $\f(\vx) = 1$ equals
the fraction of $n$-bit-vectors that are models of $\f$:

```math \label{eq:model_count_coins}
\Prob_{\SampleBV}(\f(\vx) = 1) = \sum_{\vx \in \BoolCube}\frac{1}{2^n}\f(\vx) = \frac{\#(\f)}{2^n}.
```
````

So, to compute $\Prob_{\SampleBV}(\f(\vx) = 1)$ for a complicated $\f$, it is
enough to use a model counter to compute, or approximate, $\#(\f)$. This is
simple, but it becomes powerful once we compose bit-vector predicates and reuse
their inputs. Two more observations show why.

```node
# \taxon{observation} \label{obs:2}
By \ref{eq:model_count_coins}, $\f$ can be read as a process that turns $n$
unbiased coins into a \emph{biased} coin.
```

We write $x \sim \f$ for drawing this biased coin, $x \in \Bool$, from the
distribution in \ref{eq:model_count_coins}.

```custom[latexfig] \label{fig:bool_pred}
\caption{Illustrations of the two observations above. Left: sharing inputs lets two bit-vector predicates that model biased coins also model a pair of correlated coin flips. Right: feeding correlated biased coin flips into a bit-vector predicate yields a new bit-vector predicate, and so itself models a biased coin.}
\begin{minipage}{0.45\linewidth}\centering\input{imgs/circ2.pdf_tex}\end{minipage}\hfill\begin{minipage}{0.45\linewidth}\centering\input{imgs/circ3.pdf_tex}\end{minipage}
```

```node
# \taxon{observation} \label{obs:3}
If the results of some coin flips are shared, $F: \vx \mapsto (\f(\vx), \f'(\vx))$,
then $F : \Bool^n \to \Bool^2$ models \emph{correlated} coin flips.
```

Following \ref{obs:3}, let $F$ be a map between bit-vectors,
$F : \Bool^n \to \Bool^m$. We write $\vx \sim F$ for drawing $m$ correlated
biased coin flips this way. If $\f_i(\vx) = F(\vx)_i$, then $\vx$ is the
concatenation of $m$ bit-vectors with $x_i \sim \f_i$. Together, \ref{obs:2} and
\ref{obs:3} let us study complex distributions by model counting.

````node
# \taxon{example} \label{ex:mux}
Let $\f$ and $\f'$ be the $3$-bit bit-vector predicates

```math \label{eq:range_mux}
\f : \Bool^3 \to \Bool,\quad \f(\vx) \eqdef \vx = 3, \qquad\qquad \f' : \Bool^3 \to \Bool,\quad \f'(\vx) \eqdef \vx > 3,
```

where $\vx$ is read as an unsigned integer. Define $\f \times \f'$ as their
product, $[\f \times \f'] : \vx \mapsto \big(\f(\vx), \f'(\vx)\big)$. Figure
\ref{fig:range_mux} shows the resulting map.

```custom[latexfig] \label{fig:range_mux}
\caption{Visualization of $[\f \times \f'](\vx)$. The bit sequences have the most significant bit on the left and the least significant bit on the right, e.g., $011 = 3$.}
imgs/mux_mapping.pdf_tex
```

Because $\f$ and $\f'$ share inputs, the biased coins they model are correlated
(\ref{obs:3}). Using Figure \ref{fig:range_mux}, $\f \times \f'$ induces the
following distribution over $2$-bit-vectors:

```math \label{eq:range_mux_bv}
\Prob_{\mathclap{\vy \sim \f\times \f'}}~~\big(\vy = k\big) =
\begin{cases}
  3/8 & \text{if } k = 0\\
  1/8 & \text{if } k = 1\\
  1/2 & \text{if } k = 2\\
  0 & \text{otherwise}.
\end{cases}
```

Now suppose we want the probability that $k > 0$ under \ref{eq:range_mux_bv}.
By \ref{eq:model_count_coins}, it is enough to compute the model count of
$[\vx > 0]$ composed with $\f\times \f'$:

```math \label{eq:8}
\Prob_{\mathclap{\vy \sim \f\times \f'}}~~\big(\vy > 0\big)
= \frac{\#\Big([\vx > 0]\circ[\f\times \f']\Big)}{2^3} = \tfrac{5}{8}.
```

Here it is easy to read Figure \ref{fig:range_mux} directly and see that
$\#\Big([\vx > 0]\circ[\f\times \f']\Big) = 5$. With bigger circuits and more
complex properties, this reduction to model counting is far more useful.
````

### Biased Coins and Bayes' Rule {#sec:LqG8}

So far we have modeled only probability masses that are integer multiples of
$\frac{1}{2^n}$. Many examples violate this, e.g., a coin biased $\frac{1}{3}$
towards heads. We postpone an explicit treatment of biased coins to
\ref{ch:bdd}{Stochastic Games as BDDs}, and instead note that probabilistic
queries over unbiased coins already answer two model-counting queries.

````node
# \taxon{proposition} \label{prop:biased_query}
Let $\f : \Bool^n \to \Bool$ and $\psi : \Bool^n \to \Bool$ be any two
bit-vector predicates. Then

```math \label{eq:model_count_conditioned}
\Prob_{\SampleBV}(\f(\vx)=1~|~\psi(\vx)=1) = \frac{\#(\f \wedge \psi)}{\#(\psi)}.
```

\emph{Proof.} By the chain rule,

```math \label{eq:chain}
\Prob_{\SampleBV}(\f(\vx)=1~|~\psi(\vx)=1)\cdot \Prob_{\SampleBV}(\psi(\vx)=1) = \Prob_{\SampleBV}([\f \wedge \psi](\vx) = 1).
```

Replacing the unconditioned probabilities using \ref{eq:model_count_coins} gives

$$\Prob_{\SampleBV}(\f(\vx)=1~|~\psi(\vx)=1)\cdot\frac{\#(\psi)}{2^n} = \frac{\#(\f\wedge \psi)}{2^n}.$$

Multiplying both sides by $2^n$ and rearranging yields \ref{eq:model_count_conditioned}.
````

To avoid clutter, we frequently write \ref{eq:model_count_conditioned} using the
sampling notation $y \sim \f$ introduced above, but also conditioned on $\psi$:

$$\Prob_{y \sim \f}(y~|~\psi)\eqdef\Prob_{\vx \sim \BoolCube}\big(\f(\vx)=1~|~\psi(\vx)=1\big).$$

```node
# \taxon{example} \label{ex:dice}
Again, suppose we want a pair $\f, \psi$ that encodes a biased coin with
probability $\tfrac{1}{3}$ of coming up $1$. Let
$\f(\vx) \eqdef (\vx = 0)$ and $\psi(\vx) \eqdef (\vx < 3)$. Then

$$\Prob_{y \sim \f}(y_i~|~\psi) = \frac{\#(\vx = 0 \wedge \vx < 3)}{\#(\vx  < 3)} = \frac{1}{3},$$

where $\vx \in \Bool^2$ is read as an unsigned integer.
```

```node
# \taxon{remark}
In many contexts, $\#(\psi)$ can be precomputed, sometimes even without a model
counting algorithm.
```

```node
# \taxon{remark}
Computing the model count of a circuit is $\#P$-complete
\cite{bacchus2003algorithms}. In practice, moderately efficient methods for
computing or approximating $\#(\bullet)$ exist, including Monte Carlo
simulation \cite{metropolis1949monte} and weighted model counting
\cite{chavira2008probabilistic} via Binary Decision Diagrams (BDDs)
\cite{bryant1992symbolic} or repeated SAT queries
\cite{chakraborty2016algorithmic}.
```

### Encoding Rational Coins {#sec:MrQa}

\ref{prop:biased_query} tells us how to generalize \ref{ex:dice} to encode an
arbitrary coin with a rational bias. Consider a coin $y$ such that
$\Pr(y = 1) =\frac{k}{m}$, for some $k, m \in \Nat$. Let $n$ be the smallest
integer such that $m \leq 2^n$. Recalling that $\vx < k$ has exactly $k$ models
(\ref{ex:lt_models}), $y$ corresponds to feeding $n$ unbiased coins into
$\f(\vx) \eqdef \vx < k$ and conditioning on $\psi(\vx) \eqdef \vx < m$.
Finally, since $\vx < k$ implies $\vx < m$,

```math \label{eq:arb_coin}
\Prob_{y \sim \f}(y = 1~|~\psi) = \frac{\#(\vx < k)}{\#(\vx < m)} = \frac{k}{m}.
```

Since $\Prob_{\vy \sim F}( \f(\vy)~|~\psi, \psi') = \Prob_{\vy \sim
F}(\f(\vy) = 1~|~\psi \wedge \psi')$, \ref{eq:arb_coin} extends naturally to
modeling multiple input-conditioned coin flips. Biased coins are not
interesting by themselves, but, as \ref{ex:mux} shows, feeding multiple
correlated coin flips into another circuit lets us study more sophisticated
objects. Later we add a notion of state, which lets us answer non-trivial
queries about probabilistic systems by model counting.

## Distributions over Finite Sets {#sec:arb_dist}

We now return to modeling distributions over finite sets. We first seek to
systematically solve the following problem.

```node
# \taxon{problem} \label{prob:encode}
Let $Y$ be a finite set whose elements, $\hat{y}_i$, are numbered from $1$ to
$|Y|$, with the rational-valued probability distribution

$$\Prob(\hat{y}_i) = \tfrac{a_i}{m},$$

where $a_i, m \in \Nat$ and $\displaystyle \sum_{i=1}^{|Y|} a_i = m > 0$. Denote
by $\vy \in \Bool^{|Y|}$ the $1$-hot encoding of elements of $Y$, i.e.,
$y_i = 1$ iff $\vy$ corresponds to $\hat{y}_i$. Find an $n\in \Nat$, an
$n$-bit-vector function $F : \BoolCube \to \Bool^{|Y|}$, and an $n$-bit-vector
predicate $\psi$, such that

$$\Prob(\hat{y}_i) = \Prob_{\mathclap{\vy \sim F}}\;(y_i = 1~|~\psi).$$
```

A $1$-hot encoding loses no generality, since we can always feed this encoding
into a circuit that transforms it into another encoding.

### Common Denominator Method {#sec:qbPD}

Many techniques solve \ref{prob:encode}. Here we outline a straightforward
generalization of encoding a biased coin (\ref{eq:arb_coin}). The idea is to
encode $|Y|$ mutually exclusive biased coins that together form a $1$-hot
encoding of $\hat{y}_i$. Let $n$ be the smallest integer such that $m \leq 2^n$,
and define

$$b_0 \eqdef 0,\qquad b_{i+1} \eqdef b_{i} + a_i.$$

Let $\f_i : \Bool^n \to \Bool$ be the circuit

```math \label{eq:mux_gadget}
\f_i(\vx) \eqdef b_i \leq \vx < b_{i} + a_i,
```

where $\vx$ is read as an unsigned integer. By construction, $\#(\f_i) = a_i$,
and the $\f_i$ are mutually exclusive, so the product of all $\f_i$ gives a
$1$-hot encoding. Namely, letting $F : \Bool^n \to \Bool^{|Y|}$ denote
$\f_1 \times \ldots \times \f_{|Y|}$ and $\psi(\vx) \eqdef \vx < m$,

$$\Prob_{\mathclap{\vy \sim F}}\;(y_i = 1~|~\psi) = \tfrac{a_i}{m},$$

as desired.

## Sequential Circuits {#sec:seq_circuits}

We want to study sequential probabilistic systems, e.g., stochastic games. We
begin by formalizing sequential circuits.

```custom[latexfig] \label{fig:seq_circ}
\caption{A sequential circuit where the first $p$ bits of input and output are marked with black rectangles, to show that they are the previous and next state respectively.}
imgs/seq_circ.pdf_tex
```

```custom[latexfig] \label{fig:histx}
\caption{A sequential circuit that tests whether $x$ is currently $1$ and ($\wedge$) whether $x$ has historically been $1$. The latch ($\vs_0 = 1$) cuts the circuit's cyclic dependency.}
imgs/historically.pdf_tex
```

```node
# \taxon{definition}
Let $n, m,$ and $p$ be natural numbers. A \strong{sequential circuit} is a
tuple $C = (\vs_0, F)$, where $F : \Bool^{p + n} \to \Bool^{p + m}$ is the
transition function and $\vs_0 \in \Bool^p$ is the initial state. To every
sequence of inputs $\va_1, \va_2, \ldots \in \Bool^n$, associate a sequence of
states $\vs_1, \vs_2, \ldots \in \Bool^p$ and outputs
$\vy_1, \vy_2, \ldots \in \Bool^m$ by

$$\vs_{i}\concat\vy_i = F(\vs_{i-1}, \va_i).$$

If $m = 1$, we call $C$ a \strong{monitor}.
```

```node
# \taxon{example}
Figure \ref{fig:histx} is a sequential circuit that checks whether $x$ has been
constantly $1$. Formally, if $\f(\vx) \eqdef x_0 \wedge x_1$, then
$F(\vx) \eqdef \f(\vx).\f(\vx)$ and $\vs_0 = 1$. Because circuits can reuse
outputs, $\f(\vx)$ is computed only once in Figure \ref{fig:histx}.
```

We can reduce the execution of a fixed number of steps of a sequential circuit,
$C = (\vs_0, F)$, back to a bit-vector function, simply by composing $F$ with
itself — akin to bounded model checking \cite{biere2003bounded}.

```custom[latexfig] \label{fig:unroll}
\caption{The sequential circuit of the previous figure unrolled for $3$ steps. As before, the first two inputs and outputs of each copy of $F$ are the state. The first copy of $F$ has its state inputs grounded, to show that $\vs_0 = (0, 0)$.}
imgs/unrolled_circ.pdf_tex
```

````node
# \taxon{definition}
Let $C = (\vs_0, F)$ be a sequential circuit with $n$ inputs, $p$ states, and
$m$ outputs, and let $\LAST_m : \Bool^{p + m} \to \Bool^m$ be the bit-vector
function that returns the last $m$ bits of its input. For all times
$\tau \in \Nat$, define the \strong{$\tau$-unrolling} of $C$ as the map

```math \label{eq:unroll}
\UNROLL_C^\tau : \Bool^{\tau\cdot n} \to \Bool^m,\qquad \UNROLL_C^\tau(a_1. a_2. \ldots . a_{\tau}) \eqdef \LAST_m \circ F(\ldots F(F(F(x_0, a_1), a_2), a_3), \ldots, a_{\tau}),
```

where each $a_i$ is a bit-vector in $\BoolCube$.
````

Since unrolling a monitor gives a Boolean predicate, \ref{obs:1}, \ref{obs:2},
and \ref{obs:3} extend naturally to sequential circuits. This suggests
extending our sampling notation to sequential circuits. Given a sequential
circuit $C$ and a monitor $\psi$ to condition on, we define $\vx \tausim{\tau} C$
so that

```math \label{eq:seqcirc_sample}
\Prob_{\vx \tausim{\tau} C}(\vx~|~\psi) \eqdef \Prob_{\vx \sim \UNROLL_{C}^\tau}(\vx~|~\UNROLL_{\psi}^\tau).
```

### Encoding Stochastic Games {#sec:C5Gp}

```custom[latexfig] \label{fig:monitor}
\caption{Recipe for modeling dynamical systems as sequential circuits.}
imgs/monitor2.pdf_tex
```

\ref{eq:seqcirc_sample} is useful because it lets us study stochastic games
with tools like SAT solvers and Binary Decision Diagrams
(\ref{ch:bdd}{Stochastic Games as BDDs}). For example, as Figure
\ref{fig:monitor} shows, the combination of a task $\spec$ and a stochastic
game $M=\langle S, s_0, \Act, P \rangle$ can be modeled as three sequential
circuits: the dynamics ($P$), a task monitor, and an assumption monitor. The
dynamics circuit models the distribution $P$, so its action inputs are split
into $\pOne$ and $\pTwo$ inputs. The task monitor takes the current state as
input and outputs $1$ iff the sequence of states seen so far would be accepting
if the episode ended now. The assumption monitor similarly checks whether the
sequence of states would satisfy the assumption $\psi$ if the episode ended
now. If the dynamics circuit does not depend on the current action inputs, it
corresponds to a Markov chain; if it does not depend on the $\pTwo$ inputs, it
corresponds to an MDP.

```node
# \taxon{remark}
Recall that when maximum causal entropy coincides with maximum entropy, the
forecasting policy $\policy_\spec$ and the likelihood of the demonstrations
depend entirely on the estimated competency of the agent, $p_\spec$, and the
competency of an agent that applies actions uniformly at random, $q_\spec$. A
circuit representation of the dynamics reduces computing $q_\spec$ to a model
counting query.
```

````node
# \taxon{example} \label{ex:sailor}
Consider the 1-d variant of the classic drunken-sailor random walk. A sailor
walks along a pier, and with each step stumbles forward one plank, backward one
plank, or stays on the same plank. The pier is $11$ planks long, and if the
sailor visits the central plank more than $3$ times, the plank breaks and the
sailor falls into the water. The sailor starts on the middle plank; the
probability of moving forward is $2/6$, backward is $1/6$, and of not moving is
$3/6$. What is the probability that the sailor breaks a plank within $10$
steps?

```custom[latexfig] \label{fig:chain}
\caption{Illustration of a "1-hot" encoding of a chain graph. The right and left arrows are arithmetic right ($\gg 1$) and left ($\ll 1$) shifts of the state.}
imgs/1dgrid.pdf_tex
```

```custom[latexfig] \label{fig:1dgrid_circ}
\caption{"1-hot" encoding of a chain graph as a sequential circuit. Each MUX gate uses its top input to select which of its two other inputs to output.}
imgs/1dgrid_circ.pdf_tex
```

The dynamics correspond to a 1-d finite chain (Figure \ref{fig:chain}). Figure
\ref{fig:1dgrid_circ} gives an example encoding of such a chain as a sequential
circuit. The monitor is a sequential circuit for the regular language
$(.^*\vs_0.^*\vs_0.^*\vs_0.^*)$, which can be compiled efficiently into a
sequential circuit \cite{DBLP:journals/corr/abs-1801-08979}. The policy is some
circuit that models the probability distribution over actions, which, using the
inputs in Figure \ref{fig:1dgrid_circ}, means modeling two independent biased
coin flips: $\Pr(\text{enable} = 0) = \frac{1}{2}$ and
$\Pr(\text{direction} = 0) = \frac{2}{3}$. As in the previous section
(\ref{eq:arb_coin}), we can model the direction coin by feeding the output of
$\f_{\text{direction}}(\vx) = \vx < 2$ into the direction input in Figure
\ref{fig:1dgrid_circ}, and conditioning on $\vx < 3$, where $\vx \in \Bool^2$.
Similarly, using a disjoint set of inputs, we encode the enable coin by feeding
the output of $\f_{\text{enable}}(\vx') = \vx' < 1$ into the enable input of
Figure \ref{fig:1dgrid_circ}. Figure \ref{fig:drunken_sailor} summarizes the
resulting sequential circuit, $C_{ds}$.

```custom[latexfig] \label{fig:drunken_sailor}
\caption{Drunken-sailor policy circuit, $C_{ds}$.}
imgs/policy.pdf_tex
```

Let $C_{valid}$ be the monitor that checks $\vx < 3$ at all time steps. Then the
probability of the sailor falling into the water within the first $50$ steps is

$$\Prob\;(\text{sailor falls into water}) = \Prob_{~~~\mathclap{x \tausim{50} C_{ds}}}\;(x = 1~|~C_{valid}) = \frac{25398396}{6^{10}} \approx 0.42.$$
````

```custom[latexfig] \label{fig:gw8x8_bits}
\caption{Running example gridworld.}
imgs/gw8x8_bits.pdf_tex
```

```node
# \taxon{example}
Consider modeling the dynamics of the $8\times 8$ gridworld of our running
example (Figure \ref{fig:gw8x8_bits}). As before, we use a 1-hot encoding of
position: let states $s\in S$ be a bit-vector $s = x\concat y$ where
$x, y\in \{0, 1\}^8$. We represent the action input as a bit-vector,
$a = a_1\concat a_2 \in \{0, 1\}^2$, where $a_1$ picks which coordinate, $x$ or
$y$, the agent moves along, and $a_2$ picks the direction, forward or backward.
Let $c$ be a coin flip $c \in \{0, 1\}$ with probability $\tfrac{1}{32}$ of
being $1$, encoding a $\tfrac{1}{32}$ chance of slipping and moving down in
the gridworld. The dynamics circuit is then the function

$$\hat{P}(x\concat y, a, c) =
\begin{cases}
    \hat{P}(x\concat y, 1\concat 0, 0) & \text{if  } c = 1\\
    (x \ll 1)\concat y & \text{else if  } a = 0\concat 0\\
    (x \gg 1)\concat y & \text{else if  } a = 0\concat 1\\
    x\concat (y \ll 1) & \text{else if  } a = 1\concat 0\\
    x\concat (y \gg 1) & \text{else if  } a = 1\concat 1
\end{cases}.$$

To enforce the Luce axiom and keep the agent from leaving the grid, we add an
assumption circuit that checks that $x$ and $y$ never become $0$. Because the
left-shift ($\ll$) and right-shift ($\gg$) are logical shifts,
$1\concat 0 \ll 1 = 0$ and $0\concat 1\gg 1 =0$; this condition enforces that
$A(s)$ contains only actions that do not leave the grid.
```

## Bibliographic Notes {#sec:RV9e}

With an eye towards realizing a maximum entropy planner, we systematically
built a framework for modeling probabilistic systems as model counting
problems. Starting from unbiased coins, we built biased coins, correlated
coins, and conditional probabilities. We discussed how to model arbitrary
distributions over finite sets, and how to combine these building blocks into
sequential systems. These building blocks have been used in previous work
(e.g., \cite{DBLP:conf/nips/Vazquez-Chanlatte18,rabe2014symbolic}), but we
believe that making the modeling techniques explicit will enable future case
studies of probabilistic systems with SAT-based model counting algorithms.

This work connects to the literature in two main ways. First, we give an
encoding of probabilistic systems as sequential circuits that, once unrolled,
is suited to model counting algorithms. Many encodings of probabilistic systems
as \emph{weighted} model counting problems have been proposed
\cite{sang2005performing,chavira2008probabilistic,dalvi2007efficient}, which
has spurred the adaptation of unweighted model counting algorithms to weighted
model counting \cite{sang2005performing,choi2013dynamic,chakraborty2014distribution}.
Such adaptations need expert knowledge of a model counter's inner workings,
which makes it hard to transfer advances from unweighted to weighted model
counting. So, techniques for efficient, automated reductions from weighted
model counting to unweighted model counting have been proposed
\cite{weighted2unweighted}. This chapter continues in that direction, by
providing a framework that encodes probabilistic systems and inferences on them
\emph{directly} as unweighted model counting problems. Such reductions are
appealing because, as far as we know, weighted model counting algorithms give
no major advantage over unweighted ones.

This work is also closely related to work on simulating discrete distributions
from a stream of random bits. This framework, the random bit model, was first
introduced by von Neumann \cite{von1963various} and has since spawned many
techniques (for a detailed survey, see \cite{lumbroso2013optimal}). One goal of
this chapter has been to show how to draw on this literature to build new
encodings of probabilistic circuits.
