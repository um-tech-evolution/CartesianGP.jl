export Parameters

immutable Parameters
    mu::Int
    lambda::Int
    mutrate::AbstractFloat
    targetfitness::AbstractFloat

    numinputs::Int
    numoutputs::Int

    numlevels::Int
    numlevelsback::Int

    funcs::Vector{Fun}
    fitfunc::Function
end

function Parameters(numinputs, numoutputs, numlevels, numlevelsback)
    mu = 1
    lambda = 4
    mutrate = 0.05
    targetfitness = 1.0
    funcs = default_funcs()
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numlevels, numlevelsback, funcs, fitfunc)
end

