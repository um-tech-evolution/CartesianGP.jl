using CGP
using Base.Test
include("../src/Goal.jl")
include("../src/Chromosome.jl")
include("../src/Execute.jl")

verbose = true
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
if verbose print("chromosome c0: "); print_chromosome(c0) end

@test execute_chromosome(c0, [ZERO.func(), ZERO.func()]) == [ZERO.func(), ZERO.func()]
@test execute_chromosome(c0, [ZERO.func(), ONE.func()]) == [ONE.func(), ZERO.func()]
@test execute_chromosome(c0, [ONE.func(), ZERO.func()]) == [ONE.func(), ZERO.func()]
@test execute_chromosome(c0, [ONE.func(), ONE.func()]) == [ZERO.func(), ONE.func()]

# The following four lines could be done in a more general and elegant way
X6 = convert(BitString,0x6)
X8 = convert(BitString,0x8)
XA = convert(BitString,0xA)
XC = convert(BitString,0xC)
# Each of the following 2 tests of execute_chromosome is equivalent to the four tests given above.
@test execute_chromosome(c0, [XC,XA]) == [X6,X8]
@test execute_chromosome(c0) == [X6,X8]   # See the second execute_chromosome function defined in Execute.jl

# test fitness
g3unp = Goal(3,3,[0xC9,0x0F,0xA5])  #Note: truth_table components are in the opposite order of what is shown in print_goal
g3pert = GoalPacked(3,3,0xA40FC9,false)   # differs in one bit from g3ni, should have fitness 0.5
@test fitness(g3unp,g3unp.truth_table)==1.0
@test fitness(unpack_goal(g3pert),g3unp.truth_table)==0.5
c0_result = execute_chromosome(c0)
g2 = Goal(c0.params.numinputs,c0.params.numoutputs,c0_result)
if verbose print("c0_result: ");print_goal(g2) end
@test fitness(g2,[X6,X8])==1.0
@test fitness(g2,[X6,XA])==0.5    # XA differs from X8 by one bit
