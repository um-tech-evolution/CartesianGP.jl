using CGP
using Base.Test

# Half adder

numinputs = 2
numoutputs = 2
numperlevel = 2
numlevels = 1
numlevelsback = 1

f0 = default_funcs()
p0 = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
c0 = Chromosome(p0)

c0.inputs = [InputNode(1, true), InputNode(2, true)]
c0.interiors = [InteriorNode(XOR, [(0, 1), (0, 2)], true) InteriorNode(AND, [(0, 1), (0, 2)], true)]
c0.outputs = [OutputNode((1, 1)), OutputNode((1, 2))]

@test execute_chromosome(c0, [ZERO.func(), ZERO.func()]) == [ZERO.func(), ZERO.func()]
@test execute_chromosome(c0, [ZERO.func(), ONE.func()]) == [ONE.func(), ZERO.func()]
@test execute_chromosome(c0, [ONE.func(), ZERO.func()]) == [ONE.func(), ZERO.func()]
@test execute_chromosome(c0, [ONE.func(), ONE.func()]) == [ZERO.func(), ONE.func()]
