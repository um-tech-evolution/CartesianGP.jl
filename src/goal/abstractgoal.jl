export AbstractGoal, satisfies, stdctx

@doc """A goal function, defined by an implicit interface.

A valid goal, `GoalType` must implement the following functions:

  * `distance(c::Circuit, g::GoalType) :: Int` - the number of input
    combinations for which the circuit returns a different result than
    that specified by the goal.
"""
abstract AbstractGoal{I,O}

@doc """Whether the given circuit fully satisfies the goal.
"""
satisfies(c::Circuit, g::AbstractGoal) = distance(c, g) == 0

@doc """Returns a standard input context for the provided goal.
"""
stdctx{I,O}(g::AbstractGoal{I,O}) = stdctx(I)

