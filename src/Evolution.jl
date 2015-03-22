export mu_lambda

function mu_lambda(p::Parameters, goal::Goal, gens::Integer, perfect::Float64)
    μ = p.mu
    λ = p.lambda
    funcs = p.funcs

    pop = @parallel (vcat) for _ = 1:(μ + λ)
        random_chromosome(p)
    end
    fit = @parallel (vcat) for c = pop
        fitness(c, goal)
    end
    perm = sortperm(fit, rev=true)

    for t = 1:gens
        if fit[perm[1]] == perfect # TODO: This is inexact
            return (pop[perm[1]], t)
        end

        mutpop = @parallel (vcat) for x = pop[perm][1:λ]
            mutate(deepcopy(x), funcs)
        end
        mutfit = @parallel (vcat) for x = mutpop
            fitness(x, goal)
        end

        newpop = vcat(pop[perm][1:μ], mutpop)
        newfit = vcat(fit[perm][1:μ], mutfit)

        pop = newpop
        fit = newfit

        perm = sortperm(fit, rev=true)
    end

    return (pop[perm][1], gens)
end

