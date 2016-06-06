import Base.setindex!, Base.getindex

export BasicGoal, distance

@doc """A basic goal implementation.

The number of inputs and outputs is stored in the type parameters I and O,
respectively. The goal's outputs give the standard input context defined
above, is stored as a vector of bit strings.

The Nth bit string represents the Nth goal output. Within each bit string, the
Kth least significant bit is the value of that output given the Kth combination
in the standard input context.

For example, the standard input context of a goal with 2 inputs and 1 outputs
looks like this:

```
[1] 1100
[2] 1010
```

Assuming our goal is an `AND` gate, the truth table would look like this:

```
[1] 1000
```

TODO: Add an internal constructor that checks for invalid `I` values.
"""
immutable BasicGoal{I,O} <: AbstractGoal{I,O}
  outputs::NTuple{O,BitString}
end

function BasicGoal(i::Int, o::Int, default::Bool)
  outputs = ntuple(i -> BitString(0b0), o)
  if default
    outputs = ntuple(i -> ~outputs[i], o)
  end
  return BasicGoal{i,o}(outputs)
end

BasicGoal(i::Int, o::Int) = BasicGoal(i, o, false)

# -------------------------------------
# AbstractGoal interface implementation
# -------------------------------------

function distance{I,O}(c::Circuit, g::BasicGoal{I,O})
end

