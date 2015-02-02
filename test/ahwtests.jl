# ahwtests.jl
# Tests the functions random_chromosome, execute_chromosome, and print_chromosome.
# The parameters of the run can be changed by editing them below.
# There is an optional integer command-line argument.  If present, it is used as
#     the random number seed.  When run with the same seed, the same random
#     chromosome will be constructed.  
# With no command line argument, a different random chromosome will be constructed on each run.
# Example run from the "src" subdirectory:  "julia ../test/ahwtests.jl 43"

using CGP
using Base.Test

const numinputs = 3
const numoutputs = 1
const numperlevel = 1
const numlevels = 6
const numlevelsback = 4

if length(ARGS) > 0
    try
        # If the user gives an interger command line argument, use it for a random number seed
        seed = int(ARGS[1])
        srand(seed)
    catch
        # if the int() conversion fails, continue without setting the random number seed
    end
end
funcs = default_funcs()
p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
chromosome = random_chromosome(p, funcs)
print_chromosome(chromosome)    # Print showing all nodes
print_chromosome(chromosome,true)  # Print showing only active nodes
if numinputs == 2
    result = execute_chromosome(chromosome, [convert(BitString,0xC), convert(BitString,0xA)])
elseif numinputs == 3
    result = execute_chromosome(chromosome, [convert(BitString,0xF0),convert(BitString,0xCC), convert(BitString,0xAA)])
elseif numinputs == 4
    result = execute_chromosome(chromosome, [convert(BitString,0xFF00),convert(BitString,0xF0F0),
        convert(BitString,0xCCCC), convert(BitString,0xAAAA)])
else
    println("Too many inputs in ahwtests.jl")
end
println(result)
