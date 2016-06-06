export Parameters

immutable Parameters
    mu::Integer
    lambda::Integer
    mutrate::AbstractFloat
    targetfitness::AbstractFloat

    numinputs::Integer
    numoutputs::Integer

    numlevels::Integer
    numlevelsback::Integer

    funcs::Vector{Func}
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

