## Relaxing the Luce axiom {#sec:luce-axiom}

Our design assumed the Luce axiom: all actions reachable from a state are distinct, i.e.

$$\forall a_1,a_2 \in A(s).\ a_1 \neq a_2 \implies \delta(s,a_1) \neq \delta(s,a_2).$$

If this is violated, pivot values become dependent. Below is an example.

```node
# \taxon{example} \label{ex:luce-violation}
Consider a demonstration $\trc = s_0 \xrightarrow{a_2} s_1$ with $A(s_0)=\{a_1,a_2\}$ and $A(s_1)\neq\emptyset$. The prefix $\prefix=s_0$ has $a_1\in A_\prefix$ and $a_2\notin A_\prefix$, so $\pival_{\prefix}=V(\prefix\concat a_1)$. The demonstration continues to $s_1$, whose pivot value is $\pival_{\trc}=V(\prefix\concat a_2)$. Because $a_2$ reaches the same subtree as $a_1$, we have

$$\pival_{\prefix}=V(\prefix\concat a_1)=V(\prefix\concat a_2)=\pival_{\prefix\concat a_2},$$

showing that pivot values are not independent.
```

This dependence breaks the surprisal‑gradient reasoning. Two logically equivalent pivots may obtain opposite gradient signs, causing DISS to label a counter‑example opposite to the intended goal. Redundant actions or states can therefore degrade performance.

### Counter-example guided action refinement {#sec:cegar}
To handle redundancy we modify DISS:
1. Start with all time‑indexed states and actions treated as equivalent, giving a chain‑shaped prefix tree with no pivots.
2. Whenever we prove two states (or actions) are distinct at a node, split the equivalence class, creating a new prefix tree.

We formalise this with \emph{value‑distinguishability}.

```node
# \taxon{definition} \label{def:value-distinguishability}
Let $\trc=\prefix\concat x\concat y$ and $\trc'=\prefix\concat x'\concat y'$ with $|x|=|x'|=1$. For a set of specifications $\Psi$, prefixes $\prefix\concat x$ and $\prefix\concat x'$ are $\Psi$‑\strong{value‑distinguishable} if there exists $\spec\in\Psi$ such that

$$V_{\spec}(\prefix\concat x) \neq V_{\spec}(\prefix\concat x').$$

When $\Psi=\ConceptClass$ we drop the $\Psi$ label.
```

If two prefixes are value‑distinguishable, their pivot values remain independent. If not, they share the same subtree.

We maintain a growing sequence of specification sets $\Psi_1 \subseteq \Psi_2 \subseteq \dots$, where $\Psi_i$ contains the specifications visited by DISS up to iteration $i$. At iteration $i$, prefixes that are not $\Psi_i$‑value‑distinguishable belong to the same equivalence class. Updating the equivalence relation whenever new distinctions are discovered yields a new prefix tree with additional pivots.

```node
# \taxon{remark} \label{rem:luce-reachable}
This variant of DISS requires knowing the set of states and actions reachable from each state. We can relax this by dynamically testing states and actions for value-distinguishability as we observe them, for example by sampling. This does not keep pivot values independent, but it does prevent conjecturing conflicting labels for equivalent paths.
```
