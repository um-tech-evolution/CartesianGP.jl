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

c0.inputs = [InputNode(1), InputNode(2)]
c0.interiors = [InteriorNode(XOR, [(0, 1), (0, 2)]) InteriorNode(AND, [(0, 1), (0, 2)])]
c0.outputs = [OutputNode((1, 1)), OutputNode((1, 2))]

# TODO: The deepcopy stuff is a bit of a hack around the fact that
# we're caching results now, so passing in a context is going to be
# deprecated. Once this gets merged into master along with the
# utilities branch, we can use the standard context for testing.

@test execute_chromosome(deepcopy(c0), [ZERO.func(), ZERO.func()]) == [ZERO.func(), ZERO.func()]
@test execute_chromosome(deepcopy(c0), [ZERO.func(), ONE.func()]) == [ONE.func(), ZERO.func()]
@test execute_chromosome(deepcopy(c0), [ONE.func(), ZERO.func()]) == [ONE.func(), ZERO.func()]
@test execute_chromosome(deepcopy(c0), [ONE.func(), ONE.func()]) == [ZERO.func(), ONE.func()]
