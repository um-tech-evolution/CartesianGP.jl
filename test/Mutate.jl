using CartesianGP
using Base.Test
include("../src/Mutate.jl")

# Utility functions

function mutate_test_parameters()
    mu = 1
    lambda = 4
    numperlevel = 2
    numlevels = 8
    numlevelsback = 8
    numinputs = 3
    numoutputs = 2
    mutrate = 0.3
    targetfitness = 1.0
    funcs = [AND, OR, XOR, NOT, ONE, ZERO ]
    fitfunc = hamming_max

    p =  Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
    return p
end

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
    return g
end

c0 = chromosome_half_adder()
cm0 = mutate(c0)
#print_chromosome(c0)
#print_chromosome(cm0)

num_iter = 20
rlist = [rand(1:1000) for i in 1:num_iter]
p = mutate_test_parameters()
for i in 1:num_iter
    r = rlist[i]
    #println("r:",r)   # If there is a problem, print r and run with it as a seed
    srand(r)
    c0 = random_chromosome(p)
    cm0 = mutate(c0)
    #print_chromosome(c0)
    #print_chromosome(cm0)
end
