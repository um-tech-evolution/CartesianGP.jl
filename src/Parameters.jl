export Parameters

immutable Parameters
    mu::Integer
    lambda::Integer
    mutrate::FloatingPoint
    targetfitness::FloatingPoint

    numinputs::Integer
    numoutputs::Integer

    numperlevel::Integer
    numlevels::Integer
    numlevelsback::Integer

    funcs::Vector{Func}
    fitfunc::Function
end

function Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
    mu = 2
    lambda = 2
    mutrate = 0.05
    targetfitness = 0.0
    funcs = default_funcs()
    fitfunc = hamming_max

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

