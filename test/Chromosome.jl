using CartesianGP
using Base.Test

# Half adder

numinputs0 = 2
numoutputs0 = 2
numperlevel0 = 2
numlevels0 = 1
numlevelsback0 = 1

f0 = default_funcs()
p0 = Parameters(numinputs0, numoutputs0, numperlevel0, numlevels0, numlevelsback0)
c0 = Chromosome(p0)

c0.inputs = [InputNode(1), InputNode(2)]
c0.interiors = [InteriorNode(XOR, [(0, 1), (0, 2)]) InteriorNode(AND, [(0, 1), (0, 2)])]
c0.outputs = [OutputNode((1, 1)), OutputNode((1, 2))]

@test execute_chromosome(c0) == BitString[0x6,0x8]
@test c0.number_active_nodes == 6

numinputs1 = 2
numoutputs1 = 2
numperlevel1 = 1
numlevels1 = 5
numlevelsback1 = 5

p1 = Parameters(numinputs1, numoutputs1, numperlevel1, numlevels1, numlevelsback1)
c1 = Chromosome(p1)

c1.inputs = [InputNode(1), InputNode(2)]
c1.interiors = Array(InteriorNode, p1.numlevels, p1.numperlevel)
c1.interiors[1,1] = InteriorNode(OR, [(0, 2), (0, 1)])
c1.interiors[2,1] = InteriorNode(XOR, [(0, 2), (0, 1)])
c1.interiors[3,1] = InteriorNode(OR, [(2, 1), (0, 2)])
c1.interiors[4,1] = InteriorNode(AND, [(1, 1), (0, 2)])
c1.interiors[5,1] = InteriorNode(AND, [(2, 1), (0, 2)])
c1.outputs = [OutputNode((5, 1)),OutputNode((4,1))]
@test execute_chromosome(c1) == BitString[0x2,0xa]
@test c1.number_active_nodes == 8
@test c1.interiors[1,1].active == true
@test c1.interiors[2,1].active == true
@test c1.interiors[3,1].active == false
@test c1.interiors[4,1].active == true
@test c1.interiors[5,1].active == true
