# Final Words {#ch:outro}

> I have discovered a truly remarkable proof of this theorem which this margin
> is too small to contain.
>
> — Pierre de Fermat, Mathematician, 1607-1665

Motivated by the problem of learning and teaching tasks from demonstrations,
this thesis contributed algorithms and theoretical machinery for
systematically mitigating the combinatorial explosions inherent in (1)
finding specifications that explain an agent's behavior, (2) finding
pedagogic demonstrations that help humans infer the specification, and (3)
robustly predicting the behavior of an agent adhering to a specification.

In the context of concept learning, specification mining, and grammatical
inference, demonstrations proved an ergonomic and sample-efficient way to
communicate formal languages and specifications. This dissertation lets a
user partially specify a system's desired behavior as example
demonstrations, then find an automaton or program that explains that
behavior.

In the context of inverse reinforcement learning, Boolean task
specifications are a class of sparse, memory-augmented rewards with explicit
support for temporal and Boolean composition. These properties, we argued,
make task specifications immune to certain classes of reward-hacking bugs
that emerge from ad-hoc composition or from perturbations to the dynamics.
Unfortunately, the discrete nature of task specifications, combined with
a-priori ignorance of what historical features are needed to encode the
demonstrated task, makes existing approaches to learning rewards from
demonstrations inapplicable.

In either case, after adapting the theory of maximum causal entropy inverse
reinforcement learning to address task specifications, the remaining
fundamental hurdle was a way to efficiently search countably infinite
representation classes for task specifications that explain (compress) a
multi-set of demonstrations. \ref{ch:DISS} addressed this with the
Demonstration Informed Specification Search (DISS) algorithm; leveraging
DISS, we efficiently learned tasks from demonstrations and adapted many
ideas from the algorithmic-teaching literature — for example,
\ref{ch:teach} showed that synthesizing pedagogic demonstrations lets a
learner communicate the nuances of a specification through demonstrations.

## Future Work {#sec:TjN1}

With an eye toward the future, we enumerate directions this dissertation
left unexplored.

### Hybrid and Continuous Dynamics {#sec:outro-hybrid-continuous}

The work on learning and teaching assumed only black-box access to the
MaxEntPlanner. A natural question is whether DISS works well in more
complex domains, e.g., continuous dynamics and hybrid systems — indeed, one
of the main motivations for the local prefix-tree perspective in
\ref{ch:DISS}. The key observation is that, so long as some form of the
Luce axiom holds (at least on the visited states and actions of the prefix
tree), any entropy-regularized planner
\cite{DBLP:journals/corr/NeuJG17} could serve as the Surprisal Guided
Sampler. One might, in particular, adapt the counterexample-driven
algorithm for relaxing the Luce axiom (\ref{sec:luce-axiom}) to maintain
approximate value distinguishability — treating actions (and states) as
equivalent if their values never deviate by more than $\delta \in \Reals$
for any task. This
would let any black-box entropy-regularized planner automatically adapt to
work with DISS, even over a continuous action (and state) space.

### Approximate and Model-Free MaxEntPlanners {#sec:outro-approximate-maxent}

In many settings, one might lack a world model and wish to approximate (or
learn) the MaxEntPlanner, e.g., with a neural network
\cite{DBLP:conf/icml/HaarnojaZAL18} or a variant of Monte Carlo tree search
\cite{DBLP:conf/nips/GrillDMMV19}. Either way, \ref{ch:DISS} gives good
evidence that DISS is not particularly sensitive to such changes: focusing
on the prefix tree and pivoting already made the algorithm agnostic to the
size of the action and state space, and empirical evidence suggests setting
the SGS temperature $\beta$ much smaller than one, so that one only needs
to identify the pivot with the largest-magnitude gradient. We also saw that
this gradient magnitude is concentrated on only a few points; since the
gradient is a function of the difference in transition probabilities, this
implies that, so long as the most surprising actions do not change, the
pivot decision stays unchanged under an approximate planner.

### Hindsight Experience Replay {#sec:outro-hindsight-replay}

A natural follow-up question is how to build such approximate planners. At
the time of this dissertation, a promising direction is to leverage the
extensive literature on model-free reinforcement learning (RL) with neural
network policies
\cite{DBLP:conf/icml/HaarnojaZAL18,DBLP:conf/icml/GeistSP19,DBLP:conf/nips/Hasselt10}.
Unfortunately, learning from sparse rewards like task specifications poses
a bootstrapping problem — it is hard to get any feedback, since applying
actions uniformly at random typically yields reward $0$. Recent work
addresses this by focusing on multi-task RL instead, which aims to learn a
universal policy taking the current task and state as input and returning
a distribution over actions. The key insight, Hindsight Experience Replay
(HER) \cite{hindsight}, is that even if an episode fails the target task, it
may perform a related task — so counterfactually relabeling the episode
with an alternative task yields non-zero reward. This enables learning
common motion and state-estimation primitives, and has even been shown to
outperform hand-crafted rewards. In entropy-regularized control, the
optimal way to relabel tasks has been shown to be maximum entropy inverse
reinforcement learning \cite{DBLP:conf/nips/EysenbachGLS20} — so DISS
presents an opportunity to realize HER on very large concept classes, e.g.,
DFAs.

### Beyond DFAs {#sec:outro-beyond-dfas}

This leads to the next unexplored direction: how do DISS and related
algorithms perform empirically on different representation classes? One
might consider learning conjunctions of DFAs to capture the compositional
nature of many tasks, syntactic concept classes such as temporal-logic
fragments, or move beyond regular languages to context-free grammars or
register automata; or try learning over a large alphabet by learning
invariants as decision trees or symbolic automata. Importantly, while DISS
is formulated to be agnostic to the underlying representation class,
increasing that class's expressiveness necessarily increases the sample
complexity \cite{kearns1994introduction} of the concept identifiers — so
one may need stronger inductive biases, e.g., from data-derived priors or
the structure of the concept class, or more iterations of DISS, to achieve
similar results. Nevertheless, such extensions would open the door to many
more applications of this thesis.

### Fixed Rewards and Learning Constraints {#sec:outro-fixed-rewards}

One of this dissertation's main academic exercises was seeing how far one
could go without assuming a Markovian reward exists. That said, something
not discussed in \ref{ch:DISS} is that \ref{lem:grad} holds even in the
presence of a \emph{fixed} Markovian reward: since the reward is fixed, it
is independent of the pivot values, so the gradient makes this term $0$.

It may then be worth applying the machinery from \ref{part:learn} to
settings where the agent trades off satisfying the task specification
against optimizing some objective. Further, as the bibliographic notes of
\ref{ch:task_spec} note, a parallel literature
\cite{DBLP:conf/wafr/ChouBO18,DBLP:conf/iclr/ScobeeS20,DBLP:conf/ccta/McPhersonSS21}
has emerged to study the limiting case where the agent is constrained to
always satisfy the task specification while optimizing some objective,
e.g., run as fast as possible while avoiding obstacles. The key conceptual
difference is that, rather than changing the reward induced by the task
specification, this literature implicitly changes the MDP to make
violating the task specification impossible — but the monotonicity in the
pivot-value change remains, e.g., removing a high-value path with a
constraint lowers the corresponding pivot value. One might therefore use
DISS to explore combinatorially large constraint spaces.

### From DISS to Markov Chain Monte Carlo (MCMC) {#sec:outro-diss-to-mcmc}

The learning problem (and the DISS algorithm) in this thesis was formulated
as maximum a-posteriori (MAP) inference. MAP inference, however, fails to
capture the entire distributional structure
\cite{DBLP:journals/mp/BassettD19} — a problem worsened here by the
discrete nature of representation classes. For example, two conflicting
hypotheses might locally explain the demonstrations while differing in an
unvisited part of the workspace. For a more global perspective, one might
marginalize over the entire belief distribution to answer queries such as
"do the demonstrations imply that the agent should avoid red tiles?" By
itself this sub-task may lack explanatory power, but answering it may
still be safety-critical, e.g., if the red tiles are lava. Answering such
queries might call for transforming DISS into a Markov chain Monte Carlo
(MCMC) method \cite{metropolis1949monte} — related to simulated annealing,
but a popular way to sample from the belief distribution rather than find
its most probable elements. Several obstacles stand in the way: the
canonical MCMC algorithm, Metropolis-Hastings \cite{hastings1970monte},
needs a proposal distribution with a non-zero, known probability of
undoing the previous proposal, which is not the case in DISS, since
aggregating constraints often makes the previous task candidate impossible
to sample; further, the SAT-based DFA identification algorithms make
computing the proposal distribution's transition probabilities non-trivial.
More investigation is needed to adapt DISS to the MCMC setting.

### Assume-Guarantee and Multi-Agent Planning {#sec:outro-assume-guarantee}

Finally, we close this dissertation with the observation that the Boolean
nature of task specifications lets them encode assume-guarantee contracts
\cite{DBLP:conf/tacas/ChatterjeeH07}. An interesting future application of
DISS would be to learn the implicit assumptions of black-box components
with known "guarantees," e.g., from a spec sheet.

An alternative direction is to use such contracts to enable organic
collaboration with other systems (and humans) on complex tasks. Viewed as a
multi-player game, one might hope to automatically infer the
\emph{assumptions} each agent makes about the other's future behavior, and
the \emph{guarantees} each agent aims to provide under those assumptions.

Consider the collaborative cooking game Overcooked, a benchmark for
human-robot collaboration \cite{DBLP:conf/nips/CarrollSHGSAD19}. Players
work together to prepare meals and, to meet deadlines, specialize — one
player preps onions while another cooks and serves them. Successful
collaboration needs each player's specialization to be compatible with and
complementary to the others', and in high-stakes domains such as
industrial manufacturing, failing to operate properly in human-robot teams
raises real fiscal and safety concerns. Formal specifications, and
particularly the well-developed theory of contracts
\cite{DBLP:conf/memocode/NuzzoITS14,DBLP:journals/tecs/PasseroneRS19,DBLP:conf/memocode/RomeoSLK18},
seem a promising way to represent such interactions. A key question is then
how to adapt DISS and its agent model to the multi-agent setting.

## Bibliographic Notes {#sec:outro-bib}

Mirroring the introduction, this section gives historical notes and
attributions for the future directions discussed above. Markus Rabe and
Christian Szegedy introduced the idea of Hindsight Experience Replay;
discussions with Benjamin Eysenbach suggested its potential connection to
maximum entropy inverse reinforcement learning. Dexter Scobee introduced
the problem of learning constraints; the observation that DISS should
apply to learning constraints came out of discussions with Kaylene
Stocking and David McPherson. Adapting DISS for MCMC was, in fact, its
initial plan — various directions and variants were discussed with Gil
Lederman and Mark Ho before ultimately settling on simulated annealing.
Finally, the ideas behind collaborative assume-guarantee reasoning derive
from work on the NSF VeHICaL project's hand-off challenge problem
\cite{pant2021model} and from conversations with Niklas Lauffer, Ameesh
Shah, Yash Pant, Dexter Scobee, Bala Thoravi, and Inigo Incer.

More generally, this thesis contributes to the VeHICaL project's mission of
"developing the foundations of verified co-design of interfaces and
control for human cyber-physical systems (h-CPS) — cyber-physical systems
that operate in concert with human operators." The theory and algorithms
developed here are steps toward a principled means for human and
autonomous systems to communicate and interact in a way that is auditable,
formally verifiable, and ergonomic to the human.
