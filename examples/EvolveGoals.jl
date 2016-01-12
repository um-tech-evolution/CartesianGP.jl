# Evolve all single output 2-input or 3-input goals, or evolve a chosen number of random 4-input goals.

# Example run:  
# >  julia -p 4  -L EvolveGoals.jl -e "run_evolve_goals(\"prun\",3,16,20,3,4)"
# Runs on 4 cores with numinputs=3, random number seed=16, genome size=20, 3 runs/goal, 4 random goals.
# Output to the file  out/prun3_16_20_3_4.csv

# Evolves all single-output 2-input and single-output 3-input goals if numinputs is set to 2 or 3
#      and number_random_goals has the default value of 0.
# Evolves random single-ouput 4-input goals if numimputs is set to 4.  
#      In this case, number_random_goals should be set in the call to run_evolve_goals.
# The chromosome length (numlevels) and the number of runs per goal can be specified.
# The random number seed can also be specified.
# To evolve all 2-input goals, run run_evolve_goals() with the second argument equal to 2
# To evolve all 3-input goals, run run_evolve_goals() with the second argument equal to 3
# To run using multiple processors, start Julia using the "-p" option, such as "julia -p 4"
#   to start with 4 processors
include("../src/CGP.jl")
using CGP

# macro similar to the @time macro except that it writes to the ost stream rather than the stdout stream.
# This definition must precede its use below.
macro otime(ex)
           quote
               local t0 = time()
               local val = $(esc(ex))
               local t1 = time()
               println(ost,"elapsed time: ", t1-t0, " seconds")
               val
           end
       end

# A high-level function to run function evolve_goals.
# it sets the summary to the filename, and max_gens to default values
# First example:  run_evolve_goals("prun",2,13,10,20)   
#   calls "evolve_goals" with numinputs=2, rseed=13,numlevels=10,runs_per_goal=20
#   and the output going to the file: prun2_13_10_20.csv
# Second example:  run_evolve_goals("prun",4,13,100,5,10)   
#   calls "evolve_goals" with numinputs=4, rseed=13,numlevels=100,runs_per_goal=5,number_random_goals=10
#   and the output going to the file: prun2_13_10_20.csv
function run_evolve_goals(filename_prefix,numinputs=2,rseed=2,num_levels=2,runs_per_goal=20,number_random_goals=0)
    directory = "out/"  # subdirectory for output CSV file
    filetype = ".csv"   # file extension
    underscore = "_"
    if number_random_goals == 0
        filename = "$directory$filename_prefix$numinputs$underscore$rseed$underscore$num_levels$underscore$runs_per_goal$filetype"
    else
        filename = "$directory$filename_prefix$numinputs$underscore$rseed$underscore$num_levels$underscore$runs_per_goal$underscore$number_random_goals$filetype"
    end
    ost = open(filename,"w")
    if numinputs == 2
        max_gens = 10000
    elseif numinputs == 3
        max_gens = 20000
    else   # numinputs == 4 or higher
        max_gens = 70000
    end
    params = Params(numinputs,1,1,num_levels,num_levels,raman_funcs)
    for id in procs()
        remotecall(id,set_globals,params,max_gens)
    end
    @otime ost = evolve_goals(ost,filename,params,runs_per_goal,max_gens,number_random_goals,rseed)
    close(ost)
end

# Sets the global variables params and max_gens
function set_globals(pp,mg)
    global params = pp
    global max_gens = mg 
end

# This is the function used by map or pmap to evolve each goal in goal_list
function p_mu_lambda(g)
    global params
    global max_gens
    (ch,gens) = mu_lambda(params,g,max_gens)
    n = ch.number_active_nodes
    (g.truth_table,gens,n)
end

# Primitive functions used in this simulation.  Same as those used by Raman and Wagner.
raman_funcs = [AND, OR, XOR, NAND, NOR]

# Computes the parameters used for this example
function Params(numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs )
    targetfitness = 1.0
    fitfunc = hamming_max
    mu = 1
    lambda = 4
    mutrate = 0.05
    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

# Computes the goal list which includes repeated elements for multiple trials per goal
function goal_list_setup(p,runs_per_goal,maxgens,number_random_goals=0)
    global max_gens = maxgens
    num_goals = 0
    if p.numinputs <= 3
        if number_random_goals == 0
            num_goals = 2^2^p.numinputs   # for numinputs == 2 or 3, evolve all goals
            goal_list = [Goal(p.numinputs,(convert(BitString,div(i,runs_per_goal)),)) for i in 0:num_goals*runs_per_goal-1]
        else # if number_random_goals != 0 then evolve random goals
            num_goals = number_random_goals
            BitString_list = [convert(BitString,rand(0:2^2^p.numinputs-1)) for i in 1:num_goals]
            goal_list = [Goal(p.numinputs,(BitString_list[div(i,runs_per_goal)+1],)) for i in 0:num_goals*runs_per_goal-1]
        end
    else
        if number_random_goals == 0
            num_goals = 8  # a default value that is computationally feasible for numinputs==4.
        else
            num_goals = number_random_goals
        end
        BitString_list = [convert(BitString,rand(0:2^2^p.numinputs-1)) for i in 1:num_goals]
        goal_list = [Goal(p.numinputs,(BitString_list[div(i,runs_per_goal)+1],)) for i in 0:num_goals*runs_per_goal-1]
    end
    return num_goals,goal_list
end

# Computes averages array which has rows corresponding to goals and 3 columns:
#    1. average number of generations per goal (not counting runs where the goal was not evolved)
#    2. average number of active nodes used per goal
#    3. number of successful (generations less than max_gens and goal was evolved) runs per goal
function averages(ng,runs_per_goal,max_gens,r)
    # Convert r which is a 1-D array with multiple entries for the runs for each goal
    #   to a 2-D array with runs_per_goal rows and num_goals columns.
    s = reshape(r,runs_per_goal,ng)
    average_array = zeros(ng,3)
    runs_per_goal_array = zeros(ng)
    for j in 1:ng
        for i in 1:runs_per_goal
            # k==1 is generations, k==2 is number of active nodes
            if s[i,j][2] == max_gens
                # do not add to average_array[j,1]
                average_array[j,2] += s[i,j][3]
                # do not add to runs_per_goal_array[j]
            else
                runs_per_goal_array[j] += 1
                for k = 1:2
                    average_array[j,k] += s[i,j][k+1]
                end
            end
        end
    end
    for j in 1:ng
        if runs_per_goal_array[j] > 0
            average_array[j,1] = average_array[j,1]/runs_per_goal_array[j]
        else
            average_array[j,1] = 0
        end 
        average_array[j,2] = average_array[j,2]/runs_per_goal
        average_array[j,3] = runs_per_goal_array[j]  # store number of successful runs in column 3
    end
    average_array
end
    
# Runs "mu_lambda" or "evolve" to evolve the goals on goal_list.  
# Does runs_per_goal evolutions of each goal.
# For each goal, the output is the goal, the average number of generations, and the average number of active nodes,
#    and the number of succesful runs.  A run is successful if the goal is found in less than max_gens.
# Creates a CSV file with the parameter settings followed by the above described output for each run.
# Also writes this information to stdout so that the user can see the progress made.
# TO DO:  Figure out how to display the information to stdout as the process runs.
function evolve_goals( outstream::IOStream, summary::AbstractString, p, runs_per_goal, max_gens, number_random_goals, rseed)
    num_goals = 0
    goal_list = Void
    num_goals,goal_list = goal_list_setup(p, runs_per_goal, max_gens, number_random_goals )
    println(outstream,summary)
    println(outstream,Dates.now())
    print(outstream,  "host:          ",readall(`hostname`))
    println(outstream,"num processes: ",length(procs()))
    print(outstream,readall(`julia -v`))
    println(outstream,"num inputs:    ",p.numinputs)
    println(outstream,"num outputs:   ",p.numoutputs)
    println(outstream,"num per level: ",p.numperlevel)
    println(outstream,"num levels:    ",p.numlevels)
    println(outstream,"levels back:   ",p.numlevelsback)
    println(outstream,"num goals:     ",num_goals)
    println(outstream,"mu:            ",p.mu)
    println(outstream,"lambda:        ",p.lambda)
    println(outstream,"mutrate:       ",p.mutrate)
    println(outstream,"rand seed:     ",rseed)
    println(outstream,"fitfunc:       ",p.fitfunc)
    # reshape in the following line converts to a row vector to get rid of commas for CSV output
    println(outstream,"funcs: ",reshape([f.name for f in p.funcs],(1,length(p.funcs))))
    println(outstream,"max gens:      ",max_gens),
    println(outstream,"runs_per_goal: ",runs_per_goal),
    srand(rseed)
    sum_gens = 0
    if length(procs()) > 1
        r = pmap(p_mu_lambda,goal_list)
    else
        r = map(p_mu_lambda,goal_list)
    end
    average_array = averages(num_goals,runs_per_goal,max_gens,r)
    @printf("goal,  gens, active,  successful_runs\n")
    println(outstream,"goal, ave_gens, ave_active, succesful_runs") # header line for CSV
    for i in 1:num_goals
        sum_gens += average_array[i,1]
        @printf(outstream,"%#x, %6.1f, %6.1f, %4.0f\n",goal_list[i*runs_per_goal].truth_table[1],average_array[i,1],average_array[i,2],average_array[i,3])
        @printf("%#x, %6.1f, %6.1f, %4.0f\n",goal_list[i*runs_per_goal].truth_table[1],average_array[i,1],average_array[i,2],average_array[i,3])
    end
    average_gens = convert(AbstractFloat,sum_gens)/num_goals
    println(outstream,"average gens: ",average_gens)
    println("average gens: ",average_gens)
    outstream
end
