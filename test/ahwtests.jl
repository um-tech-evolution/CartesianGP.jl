# ahwtests.jl
# Tests the functions random_chromosome, execute_chromosome, and print_chromosome.
# The parameters of the run can be changed by editing them below.
# There is an optional integer command-line argument.  If present, it is used as
#     the random number seed.  When run with the same seed, the same random
#     chromosome will be constructed.  
# With no command line argument, a different random chromosome will be constructed on each run.
# Example run from the "src" subdirectory:  "julia ../test/ahwtests.jl 43"

using CartesianGP
using Base.Test

# These are set in test/Chromosome.jl which is imported above
const numinputs = 3
const numoutputs = 3
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
c0 = random_chromosome(p, funcs)
result = execute_chromosome(c0)
print_chromosome(c0)    # Print showing all nodes
print_chromosome(c0,true)  # Print showing only active nodes
print("Execution result: [")
for i in 1:numoutputs
   @printf("%#X ",result[i])
end
println("]")

