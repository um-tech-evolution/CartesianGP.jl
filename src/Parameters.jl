export Parameters, default_parameters

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
end

function Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
    mu = 1
    lambda = 4
    mutrate = 0.05
    targetfitness = 0.0
    funcs = default_funcs()

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs)
end

