## Proof of Proposition \ref{prop:grad} {#sec:proofs}

The proof relies on two facts: trees have a single path between any two nodes, and the gradient of log-sum-exp is the soft-max distribution. The statement of proposition \ref{prop:grad} is repeated. Let $p_{xy}(\pival)$ be the probability of starting at node $x$ and pivoting at $y$:

$$p_{xy}(\pival)=\Pr(x \rightsquigarrow y \mid \pival)\cdot \Bigl(1-\sum_{(y,z)\in E}\Pr(y \rightsquigarrow z \mid \pival)\Bigr).$$

Then

$$\frac{\partial \hat{\surprise}}{\partial \pival_k}=\sum_{(i,j)\in \Edges,\ i\text{ ego}} \#_{(i,j)}\bigl(p_{ik}(\pival)-p_{jk}(\pival)\bigr).$$

The proof proceeds via a supporting lemma.

\taxon{lemma}

### Surprisal gradient lemma {#lem:grad}

For any nodes $i$ and $k$ in the prefix tree,

$$\frac{\partial}{\partial \pival_k}\hat{V}_i = p_{ik}.$$

\emph{Proof sketch.} When $i$ is an environment node, the transition probabilities $\Pr(i \rightsquigarrow j \mid \pival)$ are constants, so the derivative of $\hat{V}_i$ reduces to the derivative of its child $\hat{V}_j$. When $i$ is an ego node, $\hat{V}_i=\log\sum_j e^{\hat{V}_j}$, whose derivative is the soft-max $\Pr(i \rightsquigarrow j \mid \pival)$ times the derivative of $\hat{V}_j$. By induction along the unique path from $i$ to $k$, we obtain $\partial \hat{V}_i/\partial \pival_k = p_{ik}$.

\emph{Proof of the proposition.} For an ego edge $(i,j)$ we have $\ln \Pr(i \rightsquigarrow j \mid \pival)=\hat{V}_j-\hat{V}_i$. Differentiating gives $\partial \ln \Pr/\partial \pival_k = p_{jk}-p_{ik}$ by the lemma (\ref{lem:grad}), which after re-ordering yields the stated expression.
