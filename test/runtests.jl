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
    execute_chromosome(c, [true, true])
    execute_chromosome(c, [true, false])
    execute_chromosome(c, [false, true])
    execute_chromosome(c, [false, false])
end
