using CartesianGP
using Base.Test

# Utility functions

function default_parameters()
    numperlevel = 2
    numlevels = 1
    numlevelsback = 1
    numinputs = 2
    numoutputs = 2

    p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)

    return p
end

function chromosome_half_adder(numperlevel=2, numlevels=1, numlevelsback=1)
    numinputs = 2
    numoutputs = 2

    p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
    c = Chromosome(p)

    c.inputs = [InputNode(1), InputNode(2)]
    c.interiors = [InteriorNode(XOR, [(0, 1), (0, 2)]) InteriorNode(AND, [(0, 1), (0, 2)])]
    c.outputs = [OutputNode((1, 1)), OutputNode((1, 2))]

    return c
end

# 1100
# 1010

function goal_half_adder()
    g = Goal(2, (0b0110, 0b1000))

    return g
end

include("Func.jl")
include("Chromosome.jl")
include("Goal.jl")
include("Fitness.jl")
include("Evolution.jl")

numinputs = 2
numoutputs = 1
numperlevel = 1
numlevels = 10
numlevelsback = 10

funcs = default_funcs()
p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)

for _ = 1:100
    c0 = random_chromosome(p)
    # Executing on these inputs tests all possible bit combinations for inputs
    execute_chromosome(c0, [convert(BitString, 0xC), convert(BitString, 0xA)])

    # Try a mutation, right now we just want to make sure it doesn't crash
    c1 = mutate(c0, funcs)
end
