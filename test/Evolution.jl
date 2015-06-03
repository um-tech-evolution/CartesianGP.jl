using CGP
using Base.Test

# Test function mu_lambda() from Evolution.jl
# Needs to be revised

function parameters_half_adder()
    numperlevel = 1
    numlevels = 2
    numlevelsback = numlevels
    numinputs = 2
    numoutputs = 2

    mu = 1
    lambda = 4
    mutrate = 0.15
    targetfitness = 1.0
    funcs = [AND, OR, XOR]
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

# This version has one node per level
function chromosome_half_adder(numperlevel=1, numlevels=2, numlevelsback=2)
    numinputs = 2
    numoutputs = 2

    #p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
    p = parameters_half_adder()
    c = Chromosome(p)

    c.inputs = [InputNode(1), InputNode(2)]
    c.interiors = Array(InteriorNode,2,1)
    c.interiors[1,1] = InteriorNode(XOR, [(0, 1), (0, 2)])
    c.interiors[2,1] = InteriorNode(AND, [(0, 1), (0, 2)])
    c.outputs = [OutputNode((1, 1)), OutputNode((2, 1))]

    return c
end

function goal_half_adder()
    g = Goal(2, (0b0110, 0b1000))
    #g = Goal(2, (0b1000, 0b0110))

    return g
end

p = parameters_half_adder()
goal = goal_half_adder()
maxgens = 100
srand(1)

(ch,gens) = mu_lambda(p, goal, maxgens)
# The intention here is to compare ch with chromosome_half_adder(), but == does not work for comparison.
print_chromosome(ch)
ch_ha = chromosome_half_adder() 
execute_chromosome(ch_ha)   # Sets active nodes to active
print_chromosome(ch_ha)
#@test ch == ch_ha

