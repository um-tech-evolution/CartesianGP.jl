include("../src/CGP.jl")

using CGP
using Base.Test

function parameters()
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

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs)
end

function goal_half_adder()
    g = Goal(2, (0b0110, 0b1000))

    return g
end

p = parameters()
g = goal_half_adder()
n = 100

# TODO: Add correctness tests
r = mu_lambda(p, g, n)

@assert fitness(r[1], g) == p.targetfitness
@assert r[2] <= n

print_chromosome(r[1])

