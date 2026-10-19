# Stochastic Games as Circuits {#ch:circ}

This chapter introduces the circuit-based encoding of control policies and
their use in control improvisation.

```macros \label{def:circuits-notation}
We write $\f$ for a Boolean predicate.

\def\f{\varphi}
```

## Introduction {#sec:p9ny}

In this chapter, we present a circuit-based approach to encoding control policies. 
We show how circuits can be used to represent and manipulate control policies in
a computationally efficient manner.

## Preliminaries {#sec:Gg7a}

In this section, we introduce the basic definitions and notations used throughout
this chapter.

## Circuit-based Encoding {#sec:geMe}

In this section, we describe how circuits can be used to encode control policies.

We define a *circuit* as a directed acyclic graph with input and output nodes. 
Each internal node represents a basic operation such as AND, OR, or NOT, and 
each edge represents a signal flow.

```custom[latexfig] \label{fig:circuit-1}
\def\svgwidth{1in} \input{imgs/circ.pdf_tex}
```

```custom[latexfig] \label{fig:circuit-2}
\def\svgwidth{1.4in} \input{imgs/circ2.pdf_tex}
```

```custom[latexfig] \label{fig:circuit-3}
\def\svgwidth{1.1in} \input{imgs/circ3.pdf_tex}
```

## Circuit Implementation {#sec:yTlQ}

In this section, we describe how circuits can be implemented in practice.

## Circuits for Control Policies {#sec:stYr}

We now show how circuits can be used to represent control policies.

$$\text{Policy} = \text{Circuit}(\text{State}, \text{Action})$$

## Mux Mapping {#sec:C5HO}

In this section, we present how to map control policies to multiplexer (mux) circuits.

```custom[latexfig] \label{fig:mux-mapping}
\def\svgwidth{2.6in} \input{imgs/mux_mapping.pdf_tex}
```

## Sequential Circuits {#sec:1r74}

In this section, we describe how to represent sequential circuits.

```custom[latexfig] \label{fig:sequential-circuit}
\def\svgwidth{1.5in} \input{imgs/seq_circ.pdf_tex}
```

## Historical Circuits {#sec:diiN}

In this section, we introduce the concept of historical circuits.

```custom[latexfig] \label{fig:historical-circuit}
\def\svgwidth{1.5in} \input{imgs/historically.pdf_tex}
```

## Related Work {#sec:y4v4}

In this section, we discuss related work in the area of circuit-based control.

## Conclusions {#sec:l2fY}

In this chapter, we have presented a circuit-based approach to encoding control policies.
We have shown how circuits can be used to represent and manipulate control policies efficiently.