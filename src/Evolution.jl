export mu_lambda

# Executes mu-lambda evolution relative to goal starting with a random population of chromosomes
# mu is the number of parents and lambda is the number of children in each generation
# mu and lambda are components of the parameters
# gens is the maximum number of generations run
function mu_lambda(p::Parameters, goal::Goal, gens::Integer)
    mu = p.mu
    lambda = p.lambda
    funcs = p.funcs
    fitfunc = p.fitfunc
    perfect = p.targetfitness

    pop = [random_chromosome(p) for _ in 1:(mu+lambda) ]
    fit = [fitness(c,goal,fitfunc) for c in pop ]
    perm = sortperm(fit, rev=true)

    for t = 1:gens
        if fit[perm[1]] == perfect 
            return (pop[perm[1]], t)
        end
        mutpop = [mutate(x,funcs) for x in pop[perm][mu+1:mu+lambda]]
        mutfit = [fitness(x, goal, fitfunc) for x in mutpop]
        newpop = vcat(pop[perm][1:mu], mutpop)
        newfit = vcat(fit[perm][1:mu], mutfit)
        pop = newpop
        fit = newfit

        perm = sortperm(fit, rev=true)
    end

    return (pop[perm][1], gens)
end

