# Prediction and Control {#part:control}

In \ref{part:learn}, we assumed access to a maximum causal entropy planner. We
used this planner as a black box to predict the actions of an agent that tries to
perform a given task. With these predictions, we showed how to learn and teach
specifications from demonstrations. In this part, we open the black box. We study
how to build such planners efficiently when we can model the workspace as a
probabilistic sequential circuit.

This part has the following structure. \ref{ch:erci}{Improvisation in Stochastic
Games} starts with control improvisation: the decision problem that matches
entropy-regularized planning in Markov decision processes, interval Markov
decision processes, and, more generally, stochastic games. The result is a set of
planning algorithms that scale with the size of the time-unrolled stochastic
game. To keep the time-unrolled games small, we change our view in
\ref{ch:circ}{Stochastic Games as Circuits} and model probabilistic transition
systems as probabilistic circuits. This leads to \ref{ch:bdd}{Stochastic Games as
BDDs}, where we store compressed representations of probabilistic transition
systems as binary decision diagrams (BDDs). We will see that maximum causal
entropy planning can work directly on this compressed structure.
