include("../src/CGP.jl")

using CGP
using Base.Test

# TODO: Add correctness tests

function parameters_half_adder()
    numperlevel = 2
    numlevels = 1
    numlevelsback = 1
    numinputs = 2
    numoutputs = 2

    mu = 100
    lambda = 100
    mutrate = 0.05
    targetfitness = 1.0
    funcs = default_funcs()
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

function goal_half_adder()
    return Goal(2, (0b0110, 0b1000))
end

function parameters_full_adder()
    numperlevel = 3
    numlevels = 3
    numlevelsback = 2
    numinputs = 3
    numoutputs = 2

    mu = 1000
    lambda = 1000
    mutrate = 0.05
    targetfitness = 1.0
    funcs = default_funcs()
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

function goal_full_adder()
    return Goal(3, (0b10010110, 0b11101000))
end

p = parameters_half_adder()
g = goal_half_adder()
n = 100
r = mu_lambda(p, g, n)

@assert fitness(r[1], g) == p.targetfitness
@assert r[2] <= n
print_chromosome(r[1])

p = parameters_full_adder()
g = goal_full_adder()
n = 100000
r = mu_lambda(p, g, n)

@assert fitness(r[1], g) == p.targetfitness
@assert r[2] <= n
print_chromosome(r[1])
