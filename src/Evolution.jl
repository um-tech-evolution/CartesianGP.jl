# mu+lambda Evolution-strategy algorthm.

# Given:  
# mu:     base population size preserved between generations.  Usually 1 in standard CGP
# lambda:  number of added individuals undergoing fitness evaluation in each generation
# goal:    truth table representation of the Boolean function that the circuit is supposed to compute
# perfect: the perfect fitness of a circuit, i. e., the fitness of a circuit that exactly computes the goal

#   for i in 1:mu+lambda parallel do
#     pop[i]= new Chromosome
#     truth_table = execute_chromosome(pop[i])
#     fit[i] = fitness(truth_table,goal)
#   end
#   for t in 1:num_generations
#     rank = permutation of 1:mu+lambda so that fit[rank[i]] >= fit[rank[j]] for i in 1:mu and all j > i
#     if fit[rank[1]] == perfect return(pop[rank[1]]) end
#     for i in 1:mu
#       shallow copy pop[rank[i]] to newpop[i]  # copy mu most fit chromosomes to first mu positions of newpop
#       newfit[i] = fit[rank[i]]
#     end
#     for j in mu:mu+lambda parallel do
#       deep copy newpop[j % mu + 1] to newpop[j]   # duplicate mu most fit chromosomes
#       mutate newpop[j]
#       truth_table = execute_chromosome(newpop[j])
#       newfit[j] = fitness(truth_table,goal)
#     end
#     pop = newpop
#     fit = newfit
#   end
#   return chromosome[rank[1]]

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
    perm = sortperm(fit)

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

        perm = sortperm(fit)
    end

    return (pop[perm][1], gens)
end

