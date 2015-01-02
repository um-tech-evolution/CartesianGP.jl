using CGP
using Base.Test

function getparameters()
    return default_parameters(3, 3, 9, 2, 3, 1)
end

funcs = default_funcs()
parameters = getparameters()
chromosome = random_chromosome(parameters, funcs)
