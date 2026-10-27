# Teaching Tasks using Demonstrations {#ch:teach}

> "The more I think about language, the more it amazes me that people ever understand each other at all." — Kurt Gödel, Logician, 1906‑1978

In the previous chapter we argued that demonstrations are a rich, ergonomic way for a teacher to communicate task specifications to a learner. Here we flip the perspective: how can a teacher generate demonstrations that help a learner infer a given task?

```figure \label{fig:teaching-demo}
\caption{Pedagogic demonstrations aid a human learner to infer a task.}
<img src="imgs/episodic_teaching.svg" alt="Pedagogic demonstration illustration">
```

Changing perspective from learner to teacher has several benefits. First, formal
task specifications can be hard to understand, even for domain experts, so
supplementing a formal or natural-language description of a task with
carefully selected demonstrations can be invaluable. Second, alternating
teaching and learning is a foundation for future work on organic,
team-based collaboration, where team members automatically specialize given
inferred assumptions about other agents. Finally, teaching gives further
academic insight into what kind of demonstrations are helpful for learning
models.

A natural question is then how to characterize and algorithmically generate
pedagogic demonstrations. As discussed at the end of this chapter, the
perspective taken here is inspired by the literature on pragmatics
\cite{grice1975logic}, legibility \cite{DBLP:conf/hri/DraganLS13}, and showing
vs. doing \cite{DBLP:conf/nips/HoLMCA16}. The common idea across these works is
for the teacher to simulate the learner, in order to give demonstrations that
make the true reward easier to infer.

## Contributions {#sec:vcXe}

We study how to make demonstrations *surprising* under tasks we do not wish to
teach and *unsurprising* under the ground‑truth task. Using a description‑length
view, we provide a rewriting of the showing model in terms of energies. To
handle large task spaces (e.g., automata) we propose a counter‑example‑driven
algorithm that uses DISS as a surrogate learner to find pedagogic
demonstrations. Using DISS as a proxy for the learner offers two benefits:
understanding how to teach DISS gives further insight into how effective DISS
is in practice, and since DISS is designed to make minimal assumptions about
the teacher, teaching against it requires demonstrations that are pedagogic
across a variety of learners. The result is an algorithm that automatically
generates demonstrations that help a learner understand a task. We also
present a human study confirming the algorithm's efficacy.

## Pedagogic Demonstrations {#sec:vCFR}

To begin, we must define what it means for a demonstration to be pedagogic.
For inspiration, we turn to the literature on showing versus doing
\cite{DBLP:conf/nips/HoLMCA16}, which gives empirical evidence that human
teachers provide demonstrations, $\Xi = \Demos$, proportional to the belief
that the learner assigns to the ground-truth task,

```math \label{eq:showing}
P_{\text{teacher}}(\Xi \mid \spec) \propto P(\spec \mid \Xi) = \frac{P(\Xi \mid
\spec) \cdot P(\spec)}{\sum_{\spec'} P(\Xi \mid \spec') \cdot P(\spec')},
```

where $P$ is the belief the learner assigns to task $\spec$ — concretely, $P$
is a DISS learner from the previous chapter.

\taxon{remark}

### Why "showing versus doing" {#rem:showing-vs-doing-name}

The name "showing vs. doing" comes from contrasting \ref{eq:showing} with a
teacher that just "does" the task, e.g., by sampling paths using
$\policy_\spec$. In the running gridworld example, a "doing" teacher might
give two demonstrations that start near, and go directly to, the bottom
$\yellowTile$. A "showing" teacher, by contrast, is likely to give one
demonstration that illustrates that visiting $\blueTile$ requires visiting
$\brownTile$ first, and another that shows that visiting $\blueTile$ is
optional.

\taxon{remark}

### Showing versus doing for arbitrary rewards {#rem:showing-arbitrary-rewards}

The showing-versus-doing framework is actually defined for arbitrary sets of
Markovian reward functions. The technique developed here is biased toward
task specifications, but should in principle work with arbitrary rewards. As
with learning, the key difficulty in the task-specification setting is that
specifications are discrete, combinatorial objects, so it is unclear how to
teach against the whole set simultaneously.

### Description length perspective {#sec:description-length-perspective}

\ref{eq:showing} implies that the teacher is biased toward demonstrations
that are unsurprising under $\spec$ but surprising under $\spec'$. To make
this explicit, we rewrite \ref{eq:showing} by taking the negative log and
rearranging,

```math \label{eq:showing_log}
-\ln P_{\text{teacher}}(\Xi \mid \spec) = -\ln\big(P(\Xi \mid \spec) \cdot
P(\spec)\big) + \ln \sum_{\spec'} e^{\ln(P(\Xi \mid \spec') P(\spec'))} =
-\ln P(\Xi \mid \spec) - \ln P(\spec) + \LSE_{\spec'}\big(\ln P(\Xi \mid
\spec') + \ln P(\spec')\big) \eqdef U(\spec, \Xi) + \LSE_{\spec'}\big(-U(\spec',
\Xi)\big) = \LSE_{\spec'}\big(U(\spec, \Xi) - U(\spec', \Xi)\big),
```

where, as in the previous chapter, $U(\spec, \Xi) \eqdef -\ln P(\Xi \mid \spec) -
\ln P(\spec)$ is the description length (or energy). Recalling that $\LSE$
smooths the $\max$ function, minimizing \ref{eq:showing_log} (maximizing
\ref{eq:showing}) means making the energy of $\spec$ small and the energies of
other tasks $\spec'$ large.

## Generating Pedagogic Demonstrations {#sec:generating-pedagogic-demos}

We now turn to approximately solving the optimization problem implied by
\ref{eq:showing},

```math \label{eq:teach_obj}
\min_{\Xi \in \CompletePaths^m} \LSE_{\spec' \in \RepresentationClass}\big(U(\spec,
\Xi) - U(\spec', \Xi)\big).
```

Two obstacles stand in the way of optimizing \ref{eq:teach_obj} directly.
First, the $\LSE$ ranges over the entire representation
class\sidenote{This $\LSE$ is well defined because there cannot be a uniform
distribution on a countably infinite set, so $-U(\spec, \trc)$ tends to
negative infinity.}. Second, the transition system and the paths are discrete
objects with no obvious gradient. The second obstacle is easily overcome by
an optimizer such as simulated annealing. For the first, observe that if the
demonstrations $\Xi$ are fixed, \ref{eq:teach_obj} reduces to

```math \label{eq:teach_approx}
\LSE_{\spec' \in \RepresentationClass}\big(-U(\spec', \Xi)\big) \approx
\min_{\spec' \in \RepresentationClass} U(\spec', \Xi),
```

where the approximation follows because $\LSE$ smoothly approximates $\max$.
This is exactly the energy-minimization problem DISS solves in the previous
chapter, giving a simple iterative algorithm for generating pedagogic
demonstrations.

\taxon{remark}

### Generating pedagogic demonstrations {#rem:gen-ped-demo}

1. Let $n, k, n_\text{DISS}$, and $m$ be natural numbers, and let
   $\hat{\RepresentationClass} = \{\spec\}$ contain only the target task.
2. Sample $m$ demonstrations $\Xi_0$ from the optimal policy $\policy_\spec$.
3. For $i = 1, \ldots, n$:
   1. Run DISS on $\Xi_i$ for $n_\text{DISS}$ iterations, yielding a set
      $\RepresentationClass_i$.
   2. Add the $k$ most likely tasks under $\Xi_i$ from $\RepresentationClass_i$
      to $\hat{\RepresentationClass}$.
   3. Find a set of demonstrations $\Xi_i$ that approximately minimizes
      $\LSE_{\spec' \in \hat{\RepresentationClass}}\big(U(\spec, \Xi_i) -
      U(\spec', \Xi_i)\big)$.
4. Return $\Xi_n$.

The algorithm alternates between generating pedagogic demonstrations for
$\hat{\RepresentationClass}$ and expanding $\hat{\RepresentationClass}$ using
DISS. Intuitively, $\hat{\RepresentationClass}$ collects the specifications
DISS finds with non-trivial probability mass given a previous $\Xi_i$ — the
set of tasks the teacher should keep in mind while demonstrating.

\taxon{remark}

### Teaching as counterexample-guided synthesis {#rem:teaching-cegis}

This algorithm can be viewed as a form of counterexample-guided synthesis
\cite{DBLP:conf/asplos/Solar-LezamaTBSS06}, where $\RepresentationClass_i$
acts as "proof" that the current demonstration might imply another set of
tasks.

### Trajectory Optimization {#sec:trajectory-optimization}

The only missing piece is step 3.3: finding demonstrations that minimize

$$U(\Xi) \eqdef \LSE_{\spec' \in \hat{\RepresentationClass}}\big(U(\spec, \Xi) -
U(\spec', \Xi)\big).$$

Depending on the dynamical system, many techniques apply, from reinforcement
learning \cite{DBLP:books/lib/SuttonB98} to convex programming
\cite{DBLP:journals/eor/Lemarechal06}. We give a simple approach below, which,
like DISS, is based on simulated annealing.

An instance of simulated annealing needs an energy $U$ to minimize (here,
$U(\Xi)$ above), a proposal distribution $q$, a cooling schedule, and a reset
trigger. We reset every 50 iterations and linearly decay the temperature from
$T_{\max} = 100$ to $1$, as in DISS. The proposal distribution $q(\Xi' \mid
\Xi)$ is as follows.

\taxon{remark}

### Proposal distribution {#rem:proposal}

1. Pick a demonstration $\trc$ uniformly from $\Xi$.
2. Pick a prefix $\prefix$ uniformly from the prefix tree of $\trc$.
3. Sample a complete path $\trc'$ from $\policy_\spec$ that pivots at $\prefix$.
4. Replace $\trc$ with $\trc'$ to obtain $\Xi' = (\Xi \setminus \{\trc\}) \cup
   \trc'$.

This proposal is designed around the observation that, ignoring other tasks,
$U(\spec, \Xi)$ should be minimized — so we propose demonstrations from
$\policy_\spec$, biased toward small description length, and rely on
simulated annealing's hill climbing to account for other specifications. The
random pivot gives two kinds of change: small refinements from pivoting near
the end of a demonstration, and large changes from pivoting near the start.
Because the resampled path is still drawn from $\policy_\spec$, even large
changes often take similar routes, e.g., multiple ways to reach the same
bottleneck. Finally, to allow changing the starting location, we apply the
standard transformation that adds a dummy start state whose actions transition
uniformly to any location in the MDP — so pivoting on the first state becomes
equivalent to changing the starting location.

## Failure Modes {#sec:teach:failure}

A practical implementation of the above algorithm faces two particular
pitfalls, discussed below along with potential remedies.

### Competency Estimation {#sec:y4dE}

Recall that the showing distribution \ref{eq:showing_log} biases toward
demonstrations with short *relative* description length — small under $\spec$
and large under other specifications. Decoupling from the *total* description
length can give demonstrations where the teacher's behavior seems undirected,
even incompetent. In the running example, the teacher could move back and
forth within the corridor of $\blueTile$ tiles to emphasize that, despite
multiple opportunities, it does not cross $\blueTile$ — but to a human
learner this may look aimless, obscuring that the goal is to eventually
reach $\yellowTile$. Three mitigations help:

1. As in the legibility literature \cite{DBLP:conf/hri/DraganLS13}, add a
   predictability term that penalizes demonstrations unlikely under the
   expert policy. In description-length terms, this re-weights the energy
   with a hyperparameter $\alpha > 1$,
   $$U(\Xi) \eqdef \LSE_{\spec' \in \hat{\RepresentationClass}}\big(\alpha
   \cdot U(\spec, \Xi) - U(\spec', \Xi)\big).$$
   Since relative entropy (expected relative description length) is the
   cross entropy minus the entropy, $\alpha$ interpolates between minimizing
   the total and the relative number of nats needed to describe $\Xi$ —
   incentivizing directed behavior, since directed behavior has smaller
   total description length.
2. Model the learner as simultaneously estimating competency (temperature)
   and the task specification. Undirected behavior is then explicitly
   penalized: as the inferred temperature rises, $\policy_\spec$ approaches
   the uniform distribution, so all specifications approach the same
   description length, maximizing rather than minimizing the energy.
3. Include a sufficiently rich class of task specifications. If there is a
   high prior on a trivially true or false specification, the teacher must
   distinguish itself *against* uniformly random actions; if the concept
   class is expressive enough, the learning algorithm returns many distinct
   tasks that the previous demonstration failed to distinguish. Together,
   these discourage overfitting the teaching to any one specification,
   penalizing undirected behavior — though this mitigation needs multiple
   alternations between teaching against $\hat{\RepresentationClass}$ and
   expanding it with DISS.

Our implementation relies on mitigation 3, since MinDFA is expressive enough
and places a high prior on the two one-state DFAs representing the trivially
true and false tasks.

### Handling Similar Specifications {#sec:0IOg}

A subtler issue arises when the target task is effectively equivalent to many
tasks already in the representation class. Then $\hat{\RepresentationClass}$
collects tasks $\spec_1, \ldots, \spec_j$ similar to $\spec$; since $U(\spec,
\Xi) \approx U(\spec_i, \Xi)$ and $U(\spec, \Xi) - U(\spec_i, \Xi) \le 0$, the
$\LSE$ over these differences becomes less and less sensitive to the rest of
$\hat{\RepresentationClass}$, and the teacher loses its incentive to give
pedagogic demonstrations. If one can detect that $\spec$ and $\spec_i$ are
essentially equivalent, one can quotient $\RepresentationClass$ by this
(approximate) equivalence.

For example, let $\spec$ be "reach $\yellowTile$" and $\spec'$ be "reach
$\yellowTile$ at least twice." If reaching $\yellowTile$ requires visiting at
least two such tiles, e.g., because of a one-way door, the policies for the
two tasks are indistinguishable. One might then merge any specifications
whose policies have negligible KL-divergence,

$$\Big(\forall \trc \in \CompletePaths ~.~ \KL\big(\policy_\spec(\bullet \mid
\trc) \mid\mid \policy_{\spec'}(\bullet \mid \trc)\big) \le \epsilon\Big)
\implies (\spec \approx_\epsilon \spec'),$$

for some $\epsilon \ge 0$.

## Experiments {#sec:voxN}

To get a qualitative sense of how the proposed algorithm behaves, we
instantiated it for variants of the running gridworld example.

### Teaching Parameters {#sec:Ug8C}

We took the number of demonstrations $m$ and the number of DFAs added to
$\hat{\RepresentationClass}$ per iteration $k$ to both be $2$. The learner was
the same DFA-based DISS implementation from the previous chapter, with $\beta
= \tfrac{1}{4}$ and $n_\text{DISS} = 35$. The trajectory optimizer ran for
$350$ simulated-annealing iterations (so $7$ resets). The teaching algorithm
ran for $3$ iterations, with early stopping once the correct DFA was inferred
or after $15$ minutes elapsed. As a baseline, we ran the teaching algorithm
with $n = 0$, which reduces to $m$ samples from $\policy_\spec$; we call these
the \strong{showing} and \strong{doing} conditions, respectively.

### Tasks to Teach {#sec:tasks-to-teach}

We ran the teaching algorithm on 5 gridworld-task pairs, shown in
\ref{fig:teaching:experiment}. The top row shows the tasks encoded as DFAs;
the middle and bottom rows show the generated showing and doing
demonstrations for the DFA in the same column. To avoid clutter, we annotate
an action only when the agent slips due to wind (a green arrow shows the
intended direction). The five tasks, left to right, are:

1. Go to $\yellowTile$. But if you visit $\redTile$ or $\brownTile$, you must
   visit $\blueTile$ before $\yellowTile$.
2. Go to $\brownTile$ and then $\redTile$ (in that order) while avoiding
   $\yellowTile$.
3. Go to $\redTile$ and then $\yellowTile$ (in that order) while avoiding
   $\brownTile$ and $\blueTile$.
4. Go to $\redTile$. Avoid $\yellowTile$. If you visit $\brownTile$ you must
   visit $\blueTile$ before $\yellowTile$.
5. Go to $\yellowTile$. Avoid $\redTile$. If you visit $\blueTile$ you must
   visit $\brownTile$ before $\yellowTile$.

```custom[latexfig] \label{fig:teaching:experiment}
\caption{Top row: target tasks to teach, encoded as DFAs. Middle
row: pedagogic demonstrations for the task DFA in the same column.
Bottom row: demonstrations from an expert just performing the task
in the same column.}
\begin{minipage}{\textwidth}
\centering \scalebox{0.46}{\input{imgs/teaching_automata.pdf_tex}}
\end{minipage}

\begin{minipage}{\textwidth}
\centering \scalebox{0.7}{\input{imgs/teaching.pdf_tex}}
\end{minipage}

\begin{minipage}{\textwidth}
\centering \scalebox{0.7}{\input{imgs/doings.pdf_tex}}
\end{minipage}
```

### Qualitative Results {#sec:CZHQ}

The doing demonstrations generally convey which colors must always be visited
or avoided, but give little evidence of conditional logic. In the running
example (rightmost column), doing demonstrations clearly show the need to
reach $\yellowTile$, but little evidence that the agent must visit
$\blueTile$ after $\brownTile$; the corresponding showing demonstrations do
illustrate this, and further show that $\redTile$ must be avoided, since
both demonstrations ignore the shorter path to the top-right $\yellowTile$.
For tasks that only require visiting a fixed color sequence while avoiding
others, e.g., the second and third tasks, showing and doing are qualitatively
similar.

Showing demonstrations also actively exploit the dynamics' slipping to encode
extra information — visible in the first, fourth, and fifth tasks, where
conditional visitation is triggered "by accident" to hint at the intended
path to an accepting state. In the fifth column, slipping shows both that the
agent did not intend to visit $\blueTile$ and that it did not intend to visit
$\redTile$; a similar effect in the fourth task shows, after slipping into
$\brownTile$, that the intention was to go through the brown corridor to
reach $\redTile$. The first task uses the same trick to highlight that
visiting $\brownTile$ and $\redTile$ trigger conditional behavior.

### Limitations {#sec:teaching-limitations}

The first task also exposes limitations of the approach. Its demonstrations
are fairly complex and need non-trivial thought to recover the intended task
— arguably, that visiting $\brownTile$ triggers visiting $\blueTile$ is
obscured by the agent also visiting $\redTile$. One could add more
demonstrations, but the algorithm
gives no principled way to pick the optimal number, and one could try to
enforce diversity in how demonstrations traverse the task DFA, but it is
unclear how to enforce this in general. Nevertheless, teaching against DISS
produces demonstrations that better convey a target task's nuances than the
doing baseline — even when the representation class is too large to
enumerate and only moderately structured\sidenote{"Similar" DFAs can have
remarkably different languages.}.

### Human Study {#sec:Wr9H}

To further test the teaching algorithm's efficacy, we ran an online human
study on the Prolific platform \cite{prolific} with 250 participants. The
participants were told that: they would judge the rules a robot follows; the
robot operates in a gridworld with the same dynamics as the running example;
there could be any number of rules; there are three kinds of rule (go to a
color, avoid a color, if on color 1 then go to color 2); the color white is
not part of any rule; and a path is good if all rules hold and bad if any
rule fails.

\taxon{remark}

### Expressiveness of the human-study rule language {#rem:human-study-expressive}

The described representation class is expressive enough to capture many of
the tasks in MinDFA, including all the DFAs in \ref{fig:teaching:experiment}.
It is also, notably, an infinite representation class.

Each participant was blindly assigned either showing or doing demonstrations,
then ran a series of trials, one per gridworld-task pair in
\ref{fig:teaching:experiment}. Within a trial, participants watched
animations of their assigned demonstration type, then described the robot's
rules and labeled five color sequences as "good" or "bad" under their
inferred rules; a trial was scored by the fraction of correct labels. The
color and order of tasks were randomized, and we used pink, blue, brown, and
turquoise — chosen to avoid a-priori associations with specific colors, e.g.,
that red is bad.

### Human Study Results {#sec:human-study-results}

We partitioned the five trials into three groups — $\{1\}$, $\{2, 3\}$, and
$\{4, 5\}$ — based on our earlier analysis: trials 2 and 3 have no
conditional logic, trials 4 and 5 do, and trial 1 has conditional logic but,
we argued, not enough demonstrations (there are two different triggers for
visiting $\blueTile$, and three or longer demonstrations would exercise all
three paths).

```custom[latexfig] \label{fig:teaching:score_dist}
\caption{Distribution of scores in the human study, by trial group and
treatment.}
\scalebox{0.4}{\input{imgs/teaching_score_dist.pgf}}
```

```custom[latexfig] \label{fig:teaching:score_improvement}
\caption{Average score by trial group and treatment, with showing = false for
the doing treatment and showing = true for the showing treatment.}
\scalebox{0.4}{\input{imgs/teaching_score_improvement.pgf}}
```

Both \ref{fig:teaching:score_dist} and \ref{fig:teaching:score_improvement}
confirm the earlier analysis: the showing treatment did not significantly
change the score distribution for the conditional-logic-free trials (2 and
3), but did shift the distribution toward higher scores for trials with
conditional logic (4 and 5). Trial 1 shows larger variance, which we suspect
reflects whether a participant correctly inferred that visiting brown
triggers a visit to blue, as opposed to visiting red, as the demonstration
might otherwise suggest.

\taxon{remark}

### Key takeaway {#rem:teaching-key-takeaway}

The teaching algorithm can indeed help participants learn task
specifications, but care is needed to provide enough demonstrations — and
this held even when the representation classes being taught against
differed.

## Bibliographic Notes {#sec:M9eM}

The teaching algorithm in this chapter builds on prior work generating
pedagogic demonstrations for quantitative reward functions
\cite{DBLP:conf/nips/HoLMCA16}. This and related frameworks, such as
legibility \cite{DBLP:conf/hri/DraganLS13}, rely on the teacher's ability to
simulate how the learner would respond to a demonstration — a naturally
recursive process, codified in the Rational Speech Act (RSA) framework
\cite{goodman2016pragmatic}, in which teacher and learner recursively model
each other. The teacher in this chapter uses two alternations: the showing
teacher simulates the learner, and the learner simulates the doing teacher.
The key novelty here is teaching against a combinatorial representation
class such as DFAs, made possible by the DISS algorithm, which simulates a
learner minimizing the description complexity of the demonstrations.
Like DISS, the resulting algorithm is again an Oracle-Guided Inductive
Synthesis (OGIS) style algorithm
\cite{DBLP:journals/pieee/Seshia15,DBLP:journals/acta/JhaS17}: one component
proposes a candidate (here, demonstrations), and the other (here, DISS)
returns potentially problematic inferences by the simulated learner. Finally,
the similarity failure mode discussed in \ref{sec:teach:failure} has also
been observed in the reward setting, with a similar LSE re-weighting applied
to account for similar rewards \cite{bobu2020less}.
