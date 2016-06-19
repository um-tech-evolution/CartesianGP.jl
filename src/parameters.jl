export Parameters

@doc """A set of simulation parameters.

  * `mu` -
  * `lambda` -
  * `mutrate` -
  * `goalfitness` - the goal fitness value
  * `numinputs` - number of inputs to each circuit
  * `numoutputs` - number of outputs from each circuit
  * `length` - the length of each list of nodes
  * `levelsback` - the max number of nodes "back" each node may read from
  * `funcs` - functions available to nodes
  * `fitfunc` - fitness function, will usually compare each circuit to a goal
  * `nodearity` - number of inputs available to each node
"""
immutable Parameters
    mu::Int
    lambda::Int
    mutrate::AbstractFloat
    goalfitness::AbstractFloat

    numinputs::Int
    numoutputs::Int

    length::Int
    levelsback::Int

    funcs::Vector{Fun}
    fitfunc::Function
    nodearity::Int
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

