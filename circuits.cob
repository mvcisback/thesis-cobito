# Circuits

This chapter introduces the circuit-based encoding of control policies and
their use in control improvisation.

## Introduction

In this chapter, we present a circuit-based approach to encoding control policies. 
We show how circuits can be used to represent and manipulate control policies in
a computationally efficient manner.

## Preliminaries

In this section, we introduce the basic definitions and notations used throughout
this chapter.

## Circuit-based Encoding

In this section, we describe how circuits can be used to encode control policies.

We define a *circuit* as a directed acyclic graph with input and output nodes. 
Each internal node represents a basic operation such as AND, OR, or NOT, and 
each edge represents a signal flow.

```{.figure custom[latexfig] #fig:circuit-1}
\def\svgwidth{1in} \input{imgs/circ.pdf_tex}
```

```{.figure custom[latexfig] #fig:circuit-2}
\def\svgwidth{1.4in} \input{imgs/circ2.pdf_tex}
```

```{.figure custom[latexfig] #fig:circuit-3}
\def\svgwidth{1.1in} \input{imgs/circ3.pdf_tex}
```

## Circuit Implementation

In this section, we describe how circuits can be implemented in practice.

## Circuits for Control Policies

We now show how circuits can be used to represent control policies.

$$\text{Policy} = \text{Circuit}(\text{State}, \text{Action})$$

## Mux Mapping

In this section, we present how to map control policies to multiplexer (mux) circuits.

```{.figure custom[latexfig] #fig:mux-mapping}
\def\svgwidth{2.6in} \input{imgs/mux_mapping.pdf_tex}
```

## Sequential Circuits

In this section, we describe how to represent sequential circuits.

```{.figure custom[latexfig] #fig:sequential-circuit}
\def\svgwidth{1.5in} \input{imgs/seq_circ.pdf_tex}
```

## Historical Circuits

In this section, we introduce the concept of historical circuits.

```{.figure custom[latexfig] #fig:historical-circuit}
\def\svgwidth{1.5in} \input{imgs/historically.pdf_tex}
```

## Related Work

In this section, we discuss related work in the area of circuit-based control.

## Conclusions

In this chapter, we have presented a circuit-based approach to encoding control policies.
We have shown how circuits can be used to represent and manipulate control policies efficiently.