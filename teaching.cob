# Teaching Tasks using Demonstrations

> "The more I think about language, the more it amazes me that people ever understand each other at all." — Kurt Gödel, Logician, 1906‑1978

In the previous chapter we argued that demonstrations are a rich, ergonomic way for a teacher to communicate task specifications to a learner. Here we flip the perspective: how can a teacher generate demonstrations that help a learner infer a given task?

```figure \label{fig:teaching-demo}
\caption{Pedagogic demonstrations aid a human learner to infer a task.}
<img src="imgs/episodic_teaching.svg" alt="Pedagogic demonstration illustration">
```

## Contributions {#sec:vcXe}
We study how to make demonstrations *surprising* under tasks we do not wish to teach and *unsurprising* under the ground‑truth task. Using a description‑length view, we provide a rewriting of the showing model in terms of energies. To handle large task spaces (e.g., automata) we propose a counter‑example‑driven algorithm that uses DISS as a surrogate learner to find pedagogic demonstrations. We also present a human study confirming the algorithm’s efficacy.

## Pedagogic Demonstrations {#sec:vCFR}
The showing model states that a teacher draws demonstrations $\Xi$ proportionally to the learner’s belief in the true task $\spec$:

$$P_{\text{teacher}}(\Xi\mid \spec) \propto P(\spec \mid \Xi) = \frac{P(\Xi\mid \spec)\,P(\spec)}{\sum_{\spec'} P(\Xi\mid \spec')\,P(\spec')}.$$

Taking the negative log and rearranging yields an energy formulation:

$$U(\spec,\Xi) = -\ln P(\Xi\mid \spec) - \ln P(\spec),$$

and the teacher’s objective becomes

$$\min_{\Xi}\; \operatorname{LSE}_{\spec'\in \RepresentationClass}\bigl(U(\spec,\Xi) - U(\spec',\Xi)\bigr).$$

### Approximate Solution {#sec:CokX}
Directly optimising this is hard because (i) the $\operatorname{LSE}$ ranges over an infinite class and (ii) demonstrations are discrete. We approximate the $\operatorname{LSE}$ by the minimum energy task (as DISS does) and use simulated annealing to optimise over paths.

\taxon{remark}

### Generating pedagogic demonstrations {#rem:gen-ped-demo}

1. Sample $m$ demonstrations $\Xi_0$ from the optimal policy $\policy_{\spec}$.
2. For $i=1\dots n$:
   a. Run DISS on $\Xi_i$ for $n_{\text{DISS}}$ iterations, obtaining a set $\RepresentationClass_i$.
   b. Add the $k$ most likely tasks from $\RepresentationClass_i$ to a growing set $\hat{\RepresentationClass}$.
   c. Use simulated annealing to find a new set $\Xi_i$ that minimises $\operatorname{LSE}_{\spec'\in \hat{\RepresentationClass}}(U(\spec,\Xi_i)-U(\spec',\Xi_i))$.
3. Return the final $\Xi_n$.

#### Trajectory Optimisation via Simulated Annealing
The energy to minimise is $U(\Xi) = \operatorname{LSE}_{\spec'\in \hat{\RepresentationClass}}(U(\spec,\Xi)-U(\spec',\Xi))$. We use a temperature schedule linearly decreasing from 100 to 1, resetting every 50 iterations. The proposal distribution replaces a randomly chosen demonstration with a new path sampled from $\policy_{\spec}$ that pivots at a random prefix of the original path.

\taxon{remark}

### Proposal distribution {#rem:proposal}

1. Pick a demonstration $\trc$ uniformly from $\Xi$.
2. Pick a prefix $\prefix$ uniformly from the prefix tree of $\trc$.
3. Sample a complete path $\trc'$ from $\policy_{\spec}$ that pivots at $\prefix$.
4. Replace $\trc$ with $\trc'$ to obtain $\Xi'$.

## Failure Modes {#sec:N3Wk}
### Competency Estimation {#sec:y4dE}
If a teacher makes demonstrations that are too surprising under the true task, they appear undirected. Mitigations include:
1. Adding a weighting factor $\alpha>1$ to the true‑task energy, biasing toward total description length (legibility).
2. Modelling the learner as jointly inferring task and competence (temperature), penalising high‑temperature policies.
3. Enriching the task class with trivial true/false specifications, forcing the teacher to distinguish against random behaviour.

### Handling Similar Specifications {#sec:0IOg}
When many tasks are near‑identical, the $\operatorname{LSE}$ loses sensitivity. Detecting approximate equivalence (e.g., low KL divergence between policies) and quotienting the representation class mitigates this issue.

## Experiments {#sec:voxN}
We evaluated the algorithm on five grid‑world tasks. Each task was encoded as a DFA. For each task we generated *showing* (pedagogic) and *doing* (expert-only) demonstrations.

### Teaching Parameters {#sec:Ug8C}
We used $m=2$ demonstrations per iteration, added $k=2$ DFAs to the candidate set, ran DISS for $n_{\text{DISS}}=35$ iterations with $\beta=\tfrac{1}{4}$, and performed 350 simulated‑annealing steps per optimisation (7 resets). The baseline used only the initial $m$ samples (doing).

### Qualitative Results {#sec:CZHQ}
Showing demonstrations convey conditional logic (e.g., visiting $\blueTile$ after $\brownTile$) that doing demonstrations omit. They also exploit stochastic slips to highlight optional behaviours.

### Human Study {#sec:Wr9H}
We recruited 250 participants on Prolific, split between showing and doing conditions. After viewing demonstrations for each task, participants described the robot’s rules and classified five colour sequences as good/bad. Scores (0–1) showed that showing improved performance on tasks with conditional logic (tasks 4‑5) but not on purely sequential tasks (2‑3).

## Bibliographic Notes {#sec:M9eM}
This teaching algorithm builds on prior work on pedagogic demonstration generation for quantitative rewards \cite{DBLP:conf/nips/HoLMCA16} and legibility \cite{DBLP:conf/hri/DraganLS13}. It extends the Rational Speech Act (RSA) framework \cite{goodman2016pragmatic} to combinatorial task specifications (e.g., DFAs) via the DISS learner. The overall approach follows an Oracle‑Guided Inductive Synthesis (OGIS) pattern \cite{DBLP:journals/pieee/Seshia15,DBLP:journals/acta/JhaS17}, where DISS supplies counter‑examples and the teacher refines demonstrations accordingly.
