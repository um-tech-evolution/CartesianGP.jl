using CGP
#include("Mutation.jl")
export evolve

# Alternative simpler version of the mu_lambda function in Evolution.jl
# This version requires mu = 1 and does not attempt any parallelism.

#=
function Params(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
    mu = 1
    lambda = 4
    mutrate = 0.05
    targetfitness = 0
    funcs = default_funcs()
    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs)
end
=#

function Params(numinputs, numoutputs, numperlevel, numlevels, numlevelsback, mutrate, funcs )
    mu = 1
    lambda = 4
    targetfitness = 1.0
    fitfunc = hamming_max
    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end


function chromosome_half_adder(numperlevel=1, numlevels=10, numlevelsback=9)
    numinputs = 2
    numoutputs = 2

    p = Params(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
    c = Chromosome(p)

    c.inputs = [InputNode(1, true), InputNode(2, true)]
    c.interiors = [InteriorNode(XOR, [(0, 1), (0, 2)], true) InteriorNode(AND, [(0, 1), (0, 2)], true)]
    c.outputs = [OutputNode((1, 1)), OutputNode((1, 2))]

    return c
end

function evolve(p::Parameters, goal::Goal, gens::Integer)
    mu = p.mu
    if mu != 1
        error("mu must be 1 in function evolve.")
    end
    lambda = p.lambda
    funcs = p.funcs
    perfect = p.targetfitness

    pop = [ random_chromosome(p) for i in 1:lambda+1 ]


    for t in 1:gens
        fit = [fitness(x,goal) for x in pop]
        perm = sortperm(fit, rev=true) 
        if fit[perm[1]] == perfect
            return (pop[perm[1]],t)
        end
        #for i in 1:lambda+1
        #    println("i:",i,"  fit:",fit[i],"  pfit:",fit[perm[i]])
        #end
        #println("gen:",t,"  pfit:",fit[perm[1]])
        
        mutpop = vcat( [ pop[perm[1]]],[ mutate(deepcopy(pop[perm[i]])) for i in 2:lambda+1 ])
        pop = mutpop
        
    end
    fit = [ fitness(c,goal) for c in pop ]
    perm = sortperm(fit, rev=true)
    print_chromosome(pop[perm[1]])
    return (pop[perm[1]],gens)
end


