# Specifications from Demonstrations: Learning, Teaching, and Control

\strong{Marcell Jose Vazquez-Chanlatte}

Doctor of Philosophy in Computer Science, University of California, Berkeley.
Spring 2022.

Committee: Professor Sanjit A. Seshia (chair), Professor S. Shankar Sastry,
Associate Professor Anca Dragan, and Assistant Professor Steven Piantadosi.

> Dedicated with respect and appreciation to all my teachers past, present, and
> future: gods, men, and demons; being, animate and inanimate, living and dead,
> alive and dying...
>
> — Edward Espe Brown, The Tassajara Bread Book, 1970

...also my parents, siblings, and family. I would particularly like to dedicate
this thesis to my loving and supportive wife, Marissa Ramirez de Chanlatte,
without whom I would have written "who" rather than "whom".

## Abstract {#sec:abstract}

This dissertation considers the problem of learning and teaching Boolean task
specifications, such as automata, using demonstrations. The resulting framework
bridges grammatical inference and maximum-entropy inverse reinforcement learning
with applications in human-robot interaction, formal synthesis, and multi-task
reinforcement learning.

In the context of inverse reinforcement learning, Boolean task specifications are
a class of sparse memory augmented rewards with explicit support for temporal and
Boolean composition. These properties make task specifications immune to certain
classes of reward hacking bugs that emerge from ad-hoc composition or
perturbations to the dynamics. Unfortunately, the discrete nature of task
specifications combined with an a-priori ignorance of what historical features
are needed to encode the demonstrated task make existing approaches to learning
rewards from demonstrations inapplicable.

In the context of specification mining and grammatical inference, demonstrations
provide an ergonomic and sample efficient means to communicate formal languages
and specifications. For example, this dissertation enables a user to partially
specify the desired behavior of a system as example demonstrations and then find
an automata or program that explains the user's behavior. Conversely, by
synthesizing pedagogic demonstrations, this dissertation enables communicating
the nuances of a specification that may be hard to intuit from a formal
description.

In either case, this thesis contributes a collection of algorithms and
theoretical machinery for systematically mitigating combinatorial explosions
inherent in (1) finding specifications that explain an agent's behavior (2)
finding pedagogic demonstrations that help humans infer the specification and (3)
robustly predicting the behavior of an agent adhering to a specification.

## Contents {#sec:contents}

The thesis opens with three chapters of background, then has two parts, then
closes. Each entry below links to its chapter or part.

- \ref{ch:intro}{Introduction}
- \ref{ch:concepts}{Concepts and their Representations}
- \ref{ch:dyn-prelim}{Workspaces and Decision Processes}
- \ref{part:learn}{Learning and Teaching}
  - \ref{ch:task_spec}{Specifications from Demonstrations}
  - \ref{ch:DISS}{Finding Explanatory Specifications}
  - \ref{ch:teach}{Teaching Tasks using Demonstrations}
- \ref{part:control}{Prediction and Control}
  - \ref{ch:erci}{Improvisation in Stochastic Games}
  - \ref{ch:circ}{Stochastic Games as Circuits}
  - \ref{ch:bdd}{Stochastic Games as BDDs}
- \ref{ch:outro}{Final Words}

## Main ideas at a glance {#sec:glance}

Three nodes from deep inside the chapters carry the thesis. Each appears here in
place, and each links back to the chapter it belongs to.

The first is the object of study: a Boolean task specification.

\transclude{def:task-spec}

The second is the problem the thesis solves: to infer such a specification from
demonstrations.

\transclude{prob:tifd}

The third is the algorithm that solves it approximately.

\transclude{alg:diss}

## Acknowledgements {#sec:acknowledgements}

When seeking council on writing a dissertation, I was told to write my
acknowledgements first, as by the end I would be too tired to do it justice. I
must confess that I failed to heed this advice. As such, if you are absent, but
feel you made an impact on this dissertation, know that you were (probably) not
left out by malice, but by sleep deprivation.

This dissertation was made possible by the support and encouragement of my
collaborators, mentors, friends and family. In particular, I would like to thank
my advisor Sanjit A. Seshia and my committee members Shankar Sastry, Anca
Dragan, and Steven Piantadosi. I can confidently say that this dissertation would
not have taken its present form without each of their influences. In addition, I
would like to acknowledge the various collaborators and colleagues who directly
shaped my research career. For my early work on specification mining, I
acknowledge Jyo Deshmukh, Shromona Ghosh, Jim Kapinski, Oded Maler, Alex Donze,
Xiaoqing Jin, Vasu Raman and Alberto Sangiovanni Vincentelli. For my work on
learning and teaching via demonstrations, I thank Dorsa Sadigh, Ashish Tiwari,
Gil Lederman, Mark Ho, Ameesh Shah, Beyazit Yalcinkaya, Niklas Lauffer, Vint
Lee, Ben Caulfield, Dexter Scobee, Kaylene Stocking, David McPherson, and Susmit
Jha. Similarly, the control part of my thesis - ranging from control
improvisation to modeling dynamics a probabilistic circuits, wouldn't have been
possible without wonderful discussions with Markus Rabe, Daniel Fremont, Eric
Kim, Sebastian Junges, Kuldeep Meel, and Dogan Ulus.

I would also like to thank my lab mates not listed above, e.g., Edward Kim, Hazem
Torfah, Elizabeth Polgreen, Kevin Cheang, Ankush Desai, Rohit Sinha, Yash Pant,
Tomasso Dreossi, Yasser Shoukry, Federico Rocha, Pramod Subramanyan, Victoria
Tuck, and Yatin Manerkar. I would also like to thank my various flatmates: Greg
Khan, Michael Kellman, Brian Nemsick, Brian Kilberg, Grant Ho, and Sally Lape,
who helped me weather the dystopian reality of rental prices in Berkeley. And, I
would be remiss if I did not thank my family. Particularly my wife, daughter,
mother, and siblings. Thank you. I know I can be a handful.

Finally, this work was partially supported by NSF grants 1545126 (VeHICaL),
1646208 and 1837132, by the DARPA contracts FA8750–16–C–0043 (BRASS),
FA8750-18-C-0101 (Assured Autonomy) and FA8750-20-C-0156 (SDCPS), by Berkeley
Deep Drive, by Toyota under the iCyPhy center, and the US ARL Cooperative
Agreement W911NF-17-2-0196.
