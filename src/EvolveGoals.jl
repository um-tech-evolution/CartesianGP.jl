# Evolves all single-output 2-input and single-output 3-input goals.
# The chromosome length (numlevels) and the number of runs per goal can be specified.
# The random number seed can also be specified.
# To evolve all 2-input goals, run wrs2() with the appropriate arguments
# To evolve all 3-input goals, run wrs3() with the appropriate arguments
using CGP
using Dates

# Primitive functions used in this simulation.  Same as those used by Raman and Wagner.
raman_funcs = [AND, OR, XOR, NAND, NOR]

function Params(numinputs, numoutputs, numperlevel, numlevels, numlevelsback, mutrate, funcs )
    mu = 1
    lambda = 4
    targetfitness = 1.0
    fitfunc = hamming_max
    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
end

# Runs mu_lambda to evolve the goals on goal_list.  
# Does runs_per_goal evolutions of each goal.
# For each run, the output is the goal, the number of generations, and the number of active nodes.
# Creates a CSV file with the parameter settings followed by the above described output for each run.
# Also writes this information to stdout so that the user can see the progress made.
function evolve_goals( outstream::IOStream, summary::String, p::Parameters, goal_list, max_gens, runs_per_goal, rseed)
    println(outstream,summary)
    println(outstream,Dates.now())
    print(outstream,  "host:          ",readall(`hostname`))
    print(outstream,readall(`julia -v`))
    println(outstream,"num inputs:    ",p.numinputs)
    println(outstream,"num outputs:   ",p.numoutputs)
    println(outstream,"num per level: ",p.numperlevel)
    println(outstream,"num levels:    ",p.numlevels)
    println(outstream,"levels back:   ",p.numlevelsback)
    println(outstream,"mu:            ",p.mu)
    println(outstream,"lamdbda:       ",p.lambda)
    println(outstream,"mutrate:       ",p.mutrate)
    println(outstream,"rand seed:     ",rseed)
    println(outstream,"fitfunc:       ",p.fitfunc)
    # reshape in the following line converts to a row vector to get rid of commas for CSV output
    println(outstream,"funcs: ",reshape([f.name for f in p.funcs],(1,length(p.funcs))))
    println(outstream,"max gens:      ",max_gens),
    println(outstream,"runs_per_goal: ",runs_per_goal),
    outstream
    srand(rseed)
    sum_gens = 0
    for g in goal_list
        for r in 1:runs_per_goal
            (ch,gens) = mu_lambda(p,g,max_gens)
            ech = execute_chromosome(ch)
            #println(outstream,"ech: ",ech)
            #println("ech: ",ech)
            #print_chromosome(ch)
            num_active_nodes = get_number_active_nodes(ch)
            sum_gens += gens
            N = length(g.truth_table)
            for n in N:-1:1
                @printf(outstream,"%#x,",g.truth_table[n])
                @printf("%#x,",g.truth_table[n])
            end
            println(outstream,gens,",",num_active_nodes)
            println(gens,",",num_active_nodes)
            #println()
        end
    end
    average_gens = convert(FloatingPoint,sum_gens)/length(goal_list)/runs_per_goal
    println(outstream,"average gens: ",average_gens)
    println("average gens: ",average_gens)
    outstream
end

# This is the high-level function that is called to evolve all 2-input 1-output goals
# filename is the name of the CSV output file.
# rseed  is the random number seed.
# numlevels is the number of levels in the chromosome.  There is 1 interior node per interior node level.
# levelsback is set to numlevels.
# runs_per_goal is the number of runs made per goal.
function wrs2(filename::ASCIIString, rseed, numlevels, runs_per_goal )
    X0 = convert(BitString,0x0)
    XF = convert(BitString,0xF)
    goal_list2 = [Goal(2,(tt,)) for tt in [X0:XF]]
    p2 = Params(2,1,1,numlevels,numlevels,0.05,raman_funcs)
    outd = "out/"
    ost = open("$outd$filename","w")
    max_gens = 50000
    evolve_goals(ost,filename,p2,goal_list2,max_gens,runs_per_goal,rseed)
    close(ost)
end

# This is the high-level function that is called to evolve all 3-input 1-output goals
# filename is the name of the CSV output file.
# rseed  is the random number seed.
# numlevels is the number of levels in the chromosome.  There is 1 interior node per interior node level.
# levelsback is set to numlevels.
# runs_per_goal is the number of runs made per goal.
function wrs3(filename::ASCIIString, rseed, numlevels, runs_per_goal )
    X0 = convert(BitString,0x0)
    XFF = convert(BitString,0xFF)
    goal_list3 = [Goal(3,(tt,)) for tt in [X0:XFF]]
    p3 = Params(3,1,1,numlevels,numlevels,0.05,raman_funcs)
    outd = "out/"
    ost = open("$outd$filename","w")
    max_gens = 200000
    evolve_goals(ost,filename,p3,goal_list3,max_gens,runs_per_goal,rseed)
    close(ost)
end
