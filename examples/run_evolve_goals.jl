#Example command line to run this program on multiple processors:
# julia -p 4 "run_evolve_goals.jl"

@everywhere include("EvolveGoals.jl")

# Example runs.  Uncomment one of these lines
#run_evolve_goals("prun",2,3,10,4)
#run_evolve_goals("rrun",4,15,200,3,4)
#run_evolve_goals("erun",3,14,50,6)
run_evolve_goals("erun",3,14,50,6,4)
#run_evolve_goals("erun",3,14,50,20)

# In run_evolve_goals("frun",3,14,50,6),
#   numinputs = 3
#   random seed = 14
#   genome size = 50
#   number of repetitions per goal = 6
# Evolves all goals of length 3 with 6 repetitions per goal

# In run_evolve_goals("frun",4,14,200,3,4),
#   numinputs = 4
#   random seed = 14
#   genome size = 200
#   number of repetitions per goal = 3
#   number of random goals = 4

# An alternative that does not involve running this file
# julia -p 2  -L EvolveGoals.jl -e "run_evolve_goals(\"prun\",3,16,20,3,4)"
