## Bibliographic Notes {#sec:bibliographic-notes-30s}

The main difficulty for task‑specification inference from demonstrations is the intractably large (often infinite) representation class. Gradient‑based methods fail because the space of automata or logical formulas is discrete and the required memory is unknown. Prior work therefore either enumerates syntactic candidates \cite{DBLP:conf/nips/Vazquez-Chanlatte18,DBLP:conf/rss/ChouOB20,DBLP:conf/nips/ShahKSL18,DBLP:conf/icra/Yoon021} or performs simple stochastic mutations \cite{DBLP:conf/cdc/KasenbergS17,DBLP:phd/basesearch/Carrillo21}.

Our contribution is to reduce learning from demonstrations to a sequence of supervised specification‑identification problems, e.g., finding a small DFA consistent with example strings \cite{DBLP:conf/icgi/HeuleV10}, known as grammatical inference \cite{de2010grammatical}.

The resulting DISS algorithm combines simulated annealing (SA) for guided hill‑climbing and Oracle‑Guided Inductive Synthesis\sidenote{A generalization of the earlier Counter Example Guided Inductive Synthesis (CEGIS) \cite{DBLP:conf/asplos/Solar-LezamaTBSS06}.} (OGIS) \cite{DBLP:journals/pieee/Seshia15,DBLP:journals/acta/JhaS17} for iteratively constraining the search via counter‑examples. The SA component handles noisy pseudo‑examples, while OGIS provides the high‑level loop of proposing candidates and receiving corrective feedback.

Relaxing the Luce axiom fits naturally into the OGIS framework: running DISS with a current specification set serves as the learner, and checking for value‑distinguishability acts as the verifier that may split equivalence classes, refining the prefix tree.

Finally, the energy minimised by DISS corresponds to maximizing data compression \cite{DBLP:conf/cie/Adriaans07}, interpreting the learned specification as a concise description of the demonstrations.
