# Bitwise Computation Tutorial: Circuits and Goals

## Introduction

The CGP Julia package implements digital logic-gate circuit evolution
in Julia using bitwise computation. This tutorial introduces the
underlying concepts.

## Logic Gates

Logic gates are the building blocks of logic circuits. We start with 4
basic logic gates, namely NOT (`~`), AND (`&`), OR (`|`), and XOR
(`$`).

The semantics of a logic gate is described by its truth table. Here is
the truth table of the NOT gate:

A | NOT(A)
--|-------
F | T
T | F

In other words, if the input A is `T` (true), then the output is `F`
(false), and vice versa. Consistent with programming notation, we will
use `1` for true and `0` for false. And we will use the Julia symbols
shown above to denote the operation of the logic gate. Here is the
truth table using this notation:

`A`   | `~A`
------|-----
0     | 1
1     | 0

And here are the truth tables of all of the above gates in one table:

`A`   | `B`   | `~A`   | `A & B` | <code>A &#124; B</code> | `A $ B`
------|-------|--------|---------|----------|--------
0     | 0     | 1      | 0       | 0        | 0
1     | 0     | 0      | 0       | 1        | 1
0     | 1     | 1      | 0       | 1        | 1
1     | 1     | 0      | 1       | 1        | 0

Next, we will transpose the table which makes columns into rows and
rows into columns. Rows of the transposed truth table will correspond
to what is stored in a computer word.

Expression              |   |   |   |
------------------------|---|---|---|--
`A`                     | 0 | 1 | 0 | 1
`B`                     | 0 | 0 | 1 | 1
`~A`                    | 1 | 0 | 1 | 0
`A & B`                 | 0 | 0 | 0 | 1
<code>A &#124; B</code> | 0 | 1 | 1 | 1
`A $ B`                 | 0 | 1 | 1 | 0

## Circuits

Next we will look at the half-adder and full-adder circuits. These
circuits are described on
[Wikipedia](http://en.wikipedia.org/wiki/Adder_%28electronics%29). Here
is the logic diagram of the half adder (taken from the linked page).

![Half Adder](https://upload.wikimedia.org/wikipedia/commons/d/d9/Half_Adder.svg)

The truth table for this circuit in our transposed notation is:

Expression |   |   |   |
-----------|---|---|---|--
`A`        | 0 | 1 | 0 | 1
`B`        | 0 | 0 | 1 | 1
`C`        | 0 | 0 | 0 | 1
`S`        | 0 | 1 | 1 | 0

Note that the C row is the same as the `A & B` row above since output
C is just the output of an AND gate, and the S row is the same as the
`A $ B` row above since output S is just the ouput of an XOR gate.

The logic diagram for the full adder is:

![Full Adder](https://upload.wikimedia.org/wikipedia/commons/6/69/Full-adder_logic_diagram.svg)

## Hexadecimal and Octal Notation

## Goals

## Chromosomes
