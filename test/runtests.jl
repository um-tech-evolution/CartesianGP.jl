using CGP
using Base.Test

include("Func.jl")
include("Chromosome.jl")
include("Goal.jl")

numinputs = 2
numoutputs = 1
numperlevel = 1
numlevels = 10
numlevelsback = 10

funcs = default_funcs()
p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)

for _ = 1:100
    c0 = random_chromosome(p, funcs)
    # Executing on these inputs tests all possible bit combinations for inputs
    execute_chromosome(c0, [convert(BitString, 0xC), convert(BitString, 0xA)])

    # Try a mutation, right now we just want to make sure it doesn't crash
    c1 = mutate(c0, funcs)
end
