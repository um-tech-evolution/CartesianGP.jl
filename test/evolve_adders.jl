using CartesianGP
using Base.Test

# TODO: Add correctness tests

# Half adder

function parameters_half_adder()
    numperlevel = 1
    numlevels = 2
    numlevelsback = numlevels
    numinputs = 2
    numoutputs = 2

    mu = 1
    lambda = 4
    mutrate = 0.05
    targetfitness = 1.0
    funcs = [AND, OR, XOR]
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

function goal_half_adder()
    return Goal(2, (0b0110, 0b1000))
end

p = parameters_half_adder()
g = goal_half_adder()
n = 1000
r = mu_lambda(p, g, n)

println("running mu_lambda on half adder")
println("fitness:",fitness(r[1], g),"  gens:",r[2])
@assert fitness(r[1], g) == p.targetfitness
@assert r[2] <= n
print_chromosome(r[1])

#Half (single-output) full adder
function parameters_half_full_adder()
    numperlevel = 1
    numlevels = 10
    numlevelsback = numlevels
    numinputs = 3
    numoutputs = 1

    mu = 1
    lambda = 4
    mutrate = 0.12
    targetfitness = 1.0
    funcs = [AND, OR, XOR]
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

function goal_half_full_adder()
    return Goal(3, (0xe8, ))
end

p = parameters_half_full_adder()
g = goal_half_full_adder()
n = 100000
println("runing mu_lambda on half full adder")
r = mu_lambda(p, g, n)
println("generations: ",r[2])
#println("trying evolve on half full adder")
#r = evolve(p, g, n)

println("fitness:",fitness(r[1], g),"  gens:",r[2])
@assert fitness(r[1], g) == p.targetfitness
@assert r[2] <= n
print_chromosome(r[1])

# Full adder

function parameters_full_adder()
    numperlevel = 1
    numlevels = 4
    numlevelsback = numlevels
    numinputs = 3
    numoutputs = 2

    mu = 1
    lambda = 4
    mutrate = 0.1
    targetfitness = 1.0
    funcs = [AND, OR, XOR]
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

function goal_full_adder()
    return Goal(3, (0b10010110, 0b11101000))
end

p = parameters_full_adder()
g = goal_full_adder()
n = 1000000
println("runing mu_lambda on full adder with n: ",n)
r = mu_lambda(p, g, n)
println("generations: ",r[2])
@assert fitness(r[1], g) == p.targetfitness
@assert r[2] <= n
print_chromosome(r[1])
