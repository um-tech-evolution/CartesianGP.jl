# File to be loaded at Julia startup when running functions in EvolveGoals.jl.
# Example:  julia -p 4 -L Load.jl
# This assures that all processes are initialized with the appropriate code.
using CGP
using Dates
reload("EvolveGoals.jl")
