export Parameters, default_parameters

immutable Parameters
    mu::Integer
    lambda::Integer
    mutrate::FloatingPoint
    targetfitness::FloatingPoint

    numinputs::Integer
    numoutputs::Integer
    nodearity::Integer

    numperlevel::Integer
    numlevels::Integer
    numlevelsback::Integer
end

function default_parameters(numinputs, numoutputs, nodearity, numperlevel, numlevels, numlevelsback)
    mu = 1
    lambda = 4
    mutrate = 0.05
    targetfitness = 0.0

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, nodearity, numperlevel, numlevels, numlevelsback)
end

