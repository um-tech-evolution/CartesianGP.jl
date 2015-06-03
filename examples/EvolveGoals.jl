# Evolves all single-output 2-input and single-output 3-input goals.
# The chromosome length (numlevels) and the number of runs per goal can be specified.
# The random number seed can also be specified.
# To evolve all 2-input goals, run run_evolve_goals() with the second argument equal to 2
# To evolve all 3-input goals, run run_evolve_goals() with the second argument equal to 3
# See below for a more detailed example of how to run  run_evolve_goals().
# To run using multiple processors, start Julia using the "-p" option, such as "julia -p 4"
#   to start with 4 processors
using CGP
using Dates

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
# Example:  run_evolve_goals("prun",2,13,10,20)   
#   calls "evolve_goals" with numinputs=2, rseed=13,numlevels=10,runs_per_goal=20
#   and the output going to the file: prun2_13_10_20.csv
function run_evolve_goals(filename_prefix,numinputs,rseed,num_levels,runs_per_goal)
    directory = "out/"  # subdirectory for output CSV file
    filetype = ".csv"   # file extension
    underscore = "_"
    filename = "$directory$filename_prefix$numinputs$underscore$rseed$underscore$num_levels$underscore$runs_per_goal$filetype"
    ost = open(filename,"w")
    max_gens = numinputs == 2 ? 10000 : 50000
    @otime ost = evolve_goals(ost,filename,numinputs,num_levels,runs_per_goal,max_gens,rseed)
    close(ost)
end

# Primitive functions used in this simulation.  Same as those used by Raman and Wagner.
@everywhere raman_funcs = [AND, OR, XOR, NAND, NOR]

@everywhere function Params(mu,lambda,numinputs, numoutputs, numperlevel, numlevels, numlevelsback, mutrate, funcs )
    #println("Params: proc:",myid(),"  numinputs:",numinputs)
    #mu = 1
    #lambda = 4
    targetfitness = 1.0
    fitfunc = hamming_max
    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

@everywhere function global_setup(numinputs,maxgens)
    global num_inputs = numinputs
    global max_gens = maxgens
    num_inputs
end

# This is the function used by pmap to evolve each goal in goal_list
@everywhere function p_mu_lambda(g)
    (ch,gens) = mu_lambda(p,g,max_gens)
    n = get_number_active_nodes(ch)
    (g.truth_table,gens,n)
end

@everywhere function goal_list_setup(numinputs,num_levels,runs_per_goal,maxgens)
    #println("goal list setup: proc:",myid(),"  numinputs:",numinputs)
    global mutrate = 0.05
    global mu = 1
    global lambda = 4
    global num_inputs = numinputs
    global max_gens = maxgens
    global num_goals = 2^2^numinputs
    global p = Params(mu,lambda,numinputs,1,1,num_levels,num_levels,mutrate,raman_funcs)
    global goal_list = [Goal(numinputs,(convert(BitString,div(i,runs_per_goal)),)) for i in 0:num_goals*runs_per_goal-1]
    length(goal_list)
end

function averages(num_goals,runs_per_goal,r)
    s = reshape(r,runs_per_goal,num_goals)
    average_array = zeros(num_goals,2)
    for j in 1:num_goals
        for i in 1:runs_per_goal
            for k = 1:2
                average_array[j,k] += s[i,j][k+1]
            end
        end
    end
    for j in 1:num_goals
        for k in 1:2
            average_array[j,k] = average_array[j,k]/runs_per_goal
        end
    end
    average_array
end
    
# Runs "mu_lambda" or "evolve" to evolve the goals on goal_list.  
# Does runs_per_goal evolutions of each goal.
# For each goal, the output is the goal, the average number of generations, and the average number of active nodes.
# Creates a CSV file with the parameter settings followed by the above described output for each run.
# Also writes this information to stdout so that the user can see the progress made.
function evolve_goals( outstream::IOStream, summary::String, num_inputs, num_levels, runs_per_goal, max_gens, rseed)
    for proc in procs()
        lg = remotecall_fetch(proc,goal_list_setup,num_inputs, num_levels, runs_per_goal, max_gens )
    end
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
    println(outstream,"mu:            ",p.mu)
    println(outstream,"lambda:        ",p.lambda)
    println(outstream,"mutrate:       ",p.mutrate)
    println(outstream,"rand seed:     ",rseed)
    println(outstream,"fitfunc:       ",p.fitfunc)
    # reshape in the following line converts to a row vector to get rid of commas for CSV output
    println(outstream,"funcs: ",reshape([f.name for f in p.funcs],(1,length(p.funcs))))
    println(outstream,"max gens:      ",max_gens),
    println(outstream,"runs_per_goal: ",runs_per_goal),
    #println(outstream,"goal, gens, #active")   # header line for CSV
    srand(rseed)
    println(outstream,"goal, ave_gens, ave_active") # header line for CSV
    sum_gens = 0
    if length(procs()) > 1
        r = pmap(p_mu_lambda,goal_list)
    else
        r = map(p_mu_lambda,goal_list)
    end
    average_array = averages(num_goals,runs_per_goal,r)
    for i in 1:num_goals
        sum_gens += average_array[i,1]
        @printf(outstream,"%#x, %6.1f, %6.1f\n",goal_list[i*runs_per_goal].truth_table[1],average_array[i,1],average_array[i,2])
        @printf("%#x, %6.1f, %6.1f\n",goal_list[i*runs_per_goal].truth_table[1],average_array[i,1],average_array[i,2])
    end
    average_gens = convert(FloatingPoint,sum_gens)/num_goals
    #print_averages(ost,num_goals,runs_per_goal,goal_list,average_array)
    println(outstream,"average gens: ",average_gens)
    println("average gens: ",average_gens)
    outstream
end
