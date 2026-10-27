## Proof of Proposition \ref{prop:grad} $\dagger$ {#sec:proofs}

The proof relies on two facts: trees have a single path between any two nodes, and the gradient of log-sum-exp is the soft-max distribution. The statement of proposition \ref{prop:grad} is repeated. Let $p_{xy}(\pival)$ be the probability of starting at node $x$ and pivoting at $y$:

$$p_{xy}(\pival)=\Pr(x \rightsquigarrow y \mid \pival)\cdot \Bigl(1-\sum_{(y,z)\in E}\Pr(y \rightsquigarrow z \mid \pival)\Bigr).$$

Then

$$\frac{\partial \hat{\surprise}}{\partial \pival_k}=\sum_{(i,j)\in \Edges,\ i\text{ ego}} \#_{(i,j)}\bigl(p_{ik}(\pival)-p_{jk}(\pival)\bigr).$$

The proof proceeds via a supporting lemma.

```node
# \taxon{lemma} \label{lem:grad}
For any two nodes $i, k$ in the prefix tree, $\dfrac{\partial}{\partial
\pival_k} \hat{V}_i = p_{ik}$.

\emph{Proof.} Consider first the case where only a single action or state
pivots at $k$, i.e., $A_k = \emptyset$ or $S_k = \emptyset$. For any edge $(a,
b)$, if $a$ is an environment node then $\Pr(a \rightsquigarrow b \mid
\pival)$ is a constant, $q_{ab}$. Because the nodes form a tree, either $k$ is
unreachable from $i$, or exactly one edge $(i, j)$ can reach $k$ from $i$.
Thus

$$\frac{\partial \hat{V}_i}{\partial \pival_k} \eqdef \frac{\partial}{\partial
\pival_k} \sum_{\substack{(a,b) \in \Edges \\ i = a}} q_{ib} \cdot \hat{V}_b(\pival)
= \Pr(i \rightsquigarrow j \mid \pival) \cdot \begin{cases} 0 & \text{if }
\Pr(i \rightsquigarrow k) = 0,\\ \dfrac{\partial}{\partial \pival_k} \hat{V}_j(\pival) &
\text{otherwise}. \end{cases}$$

Similarly, because the derivative of LSE is the softmax function, for any ego
node $i$,

$$\frac{\partial \hat{V}_i}{\partial \pival_k} \eqdef \frac{\partial}{\partial
\pival_k} \ln \sum_{\substack{(a,b) \in \Edges \\ i = a}} \hat{V}_b(\pival) =
\begin{cases} 0 & \text{if } \Pr(i \rightsquigarrow k) = 0,\\ e^{\hat{V}_j(\pival) -
\hat{V}_i(\pival)} \cdot \dfrac{\partial}{\partial \pival_k} \hat{V}_j(\pival) &
\text{otherwise}, \end{cases}$$

where $j$ again denotes the unique child of $i$ that can reach $k$. By
definition $e^{\hat{V}_j(\pival) - \hat{V}_i(\pival)} = \Pr(i \rightsquigarrow
j \mid \pival)$ under the maximum-entropy policy induced by $\pival$; so, if
$k$ has only one pivot action (or state), the lemma follows by induction on
the path from $i$ to $k$, with base case

$$\frac{\partial \hat{V}_k}{\partial \pival_k} = \Big(1 - \sum_{(y,z) \in
\Edges} \Pr(y \rightsquigarrow z \mid \pival)\Big) \cdot \frac{\partial}{\partial
\pival_k} \pival_k,$$

since the probability of taking one of $k$'s pivot actions, reaching the
forest of subtrees $\hat{V}_k$ summarizes, is one minus the probability of
traversing an edge within the subtree. $\blacksquare$
```

\emph{Proof of the proposition.} The probability of traversing an environment
edge is constant with respect to $\pival$, so it suffices to show, for any ego
edge $(i, j)$, that $\frac{\partial}{\partial \pival_k} \ln \Pr(i
\rightsquigarrow j \mid \pival) = p_{ik} - p_{jk}$. By definition, since $i$ is
ego, $\ln \Pr(i \rightsquigarrow j \mid \pival) = \hat{V}_j(\pival) -
\hat{V}_i(\pival)$ — and the proposition follows directly from \ref{lem:grad}.
$\blacksquare$
