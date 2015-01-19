using CGP
using Base.Test

const numinputs = 2
const numoutputs = 1
const nodearity = 2
const numperlevel = 1
const numlevels = 10
const numlevelsback = 10

funcs = default_funcs()
p = Parameters(numinputs, numoutputs, nodearity, numperlevel, numlevels, numlevelsback)

for _ = 1:100
    c = random_chromosome(p, funcs)
    # Executing on these inputs tests all possible bit combinations for inputs
    execute_chromosome(c, [0xC, 0xA])
end
