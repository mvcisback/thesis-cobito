# Learning and Teaching {#part:learn}

Demonstrations are a popular and often ergonomic way to partly specify a
high-level task. But most methods that communicate through demonstrations have
one of three faults. They give no guarantee that the learned artifacts compose
safely; or they do not capture temporal properties; or they tie the task tightly
to the details of the workspace.

Because of this deficit, \ref{ch:task_spec}{Specifications from Demonstrations} argues for learning Boolean \emph{task
specifications}: a class of sparse, Boolean, non-Markovian rewards. These
specifications compose cleanly, handle historical dependencies, and resist a
class of "reward hacking bugs". The link to sparse rewards sketches a path. It
lets us adapt the literature on maximum causal entropy inverse reinforcement
learning to learn task specifications.

Three features make temporal task specifications hard to learn: the countably
infinite number of candidate tasks; an a-priori ignorance of what memory the
task needs; and the lack of gradients to guide the search for an explanatory
task. \ref{ch:DISS}{Finding Explanatory Specifications} studies these problems and gives a family of approximate
algorithms. The algorithms reduce learning from demonstrations to a series of
supervised learning problems.

Finally, in \ref{ch:teach}{Teaching Tasks using Demonstrations}, we change perspective from a learner to a teacher. This perspective has
three motivations. First, a formal task specification is hard to understand,
even for a domain expert; a few well-chosen demonstrations can help. Second,
teaching and learning in turn lay a foundation for team-based collaboration, in
which team members specialize from inferred assumptions about each other.
Finally, teaching gives academic insight into which demonstrations help a
learner.
