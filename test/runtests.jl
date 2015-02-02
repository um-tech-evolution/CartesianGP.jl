using CGP
using Base.Test

const numinputs = 2
const numoutputs = 1
const numperlevel = 1
const numlevels = 10
const numlevelsback = 10

funcs = default_funcs()
p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)

for _ = 1:100
    c0 = random_chromosome(p, funcs)
    # Executing on these inputs tests all possible bit combinations for inputs
    execute_chromosome(c0, [0xC, 0xA])

    # Try a mutation, right now we just want to make sure it doesn't crash
    c1 = mutate(c0, funcs)
end
