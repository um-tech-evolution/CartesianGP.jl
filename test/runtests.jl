using CGP
using Base.Test

const numinputs = 2
const numoutputs = 1
const nodearity = 2
const numperlevel = 1
const numlevels = 10
const numlevelsback = 10

funcs = default_funcs()
parameters = default_parameters(numinputs, numoutputs, nodearity,
                                numperlevel, numlevels, numlevelsback)
chromosome = random_chromosome(parameters, funcs)
result = execute_chromosome(chromosome, [true, false])
println(result)
