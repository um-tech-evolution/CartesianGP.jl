using CGP
export mutate

# This version added for compatibility
# the mutation rate and the functions are taken from the parameters which are passed as a component of the chromosome.
function mutate(old_c::Chromosome )
    return mutate(old_c, p.funcs)
end

# Mutate Chromosome old_c.
function mutate(old_c::Chromosome, funcs::Vector{Func} )
    p = old_c.params
    mutrate = p.mutrate
    numinputs = p.numinputs
    numoutputs = p.numoutputs
	#println("funcs: ",funcs)
	#println("old_c.interiors: ",old_c.interiors)

    # Count number of genes
    num_genes = numoutputs  # one connection per output gene
    for level = 1:p.numlevels
        for index = 1:p.numperlevel
            num_genes += 1+old_c.interiors[level,index].func.arity
        end
    end
    #println("num_genes: ",num_genes)

    # Determine number of mutations, but make sure that it is always at least 1
    num_mutations = max(1,convert(Int,floor(num_genes*mutrate)))    # doesn't seem right, but what CGP version 1.1 does)
    #println("num_mutations: ",num_mutations)
    if num_mutations >= num_genes
        error("more mutations than genes in function mutate")
    end

    new_c = Chromosome(p)

    # Choose the genes that will be modified, and store their numbers in the array genes_to_mutate
    genes_to_mutate = Array(Int,num_mutations)
    chosen_genes = Set()
    for i in 1:num_mutations
        gene = rand(1:num_genes)
        while gene in chosen_genes
            gene = rand(1:num_genes)
        end
        push!(chosen_genes,gene)
        genes_to_mutate[i] = gene
    end
    sort!(genes_to_mutate)
    #println("genes_to_mutate: ",genes_to_mutate)

    # Input nodes
    for i = 1:numinputs
        new_c.inputs[i] = old_c.inputs[i]
    end

    gene_index = 1
    genes_to_mutate_index = 1
    # Interior nodes
    new_c.interiors =  Array(InteriorNode, p.numlevels, p.numperlevel)  # Always use a new array 
    for level = 1:p.numlevels
        minlevel = max(level - p.numlevelsback, 0)
        maxlevel = level - 1
        for index = 1:p.numperlevel
            old_func = old_c[level, index].func
            # check if none of the genes in node will be mutated
            if genes_to_mutate_index > length(genes_to_mutate) || gene_index + old_func.arity < genes_to_mutate[genes_to_mutate_index]
                # no mutations in this node
                new_c.interiors[level, index] = old_c.interiors[level, index] 
                gene_index += 1+old_func.arity
                #println("continue level:",level,"  index:",index," new gene_index:",gene_index)
                continue
            end   
            new_inputs = Array(NodePosition, old_func.arity)
            new_func = old_func
            for i in 0:old_func.arity     # iterate through the genes in this node with 0 corresponding to the function
                #println("level:",level,"  index:",index,"  i:",i,"  gene_index:",gene_index,"  genes_to_mutate_index:",genes_to_mutate_index)
                if genes_to_mutate_index <= length(genes_to_mutate) && gene_index == genes_to_mutate[genes_to_mutate_index]  # mutate 
                    genes_to_mutate_index += 1
                    #println("mutate interior node")
                    if i == 0    # mutate the function
                        new_func = funcs[rand(1:end)]
                        #println("mutate the function  i:",i,"  old func:",old_func,"  new_func:",new_func)
                        if new_func.arity != old_func.arity  # change in arity
                            #println("change in arity")
                            new_inputs = Array(NodePosition, new_func.arity)   # we must generate a new node with the new arity
                            for j = 1:new_func.arity   
                                if j <= old_func.arity
                                    new_inputs[j] = old_c[level, index].inputs[j]
                                else
                                    new_inputs[j] = random_node_position(p, minlevel, maxlevel)
                                end
                                #println("j:",j,"  new_inputs[j]: ",new_inputs[j])
                            end
                            gene_index += 1+old_func.arity  # skip over mutating inputs
                            #println("new gene index:",gene_index)
                            # skip over mutating inputs
                            while genes_to_mutate_index <= length(genes_to_mutate) &&  genes_to_mutate[genes_to_mutate_index] < gene_index  
                                genes_to_mutate_index += 1
                            end
                            break   # break out of for i loop
                        end
                    else  # mutate the connection
                        new_inputs[i] = random_node_position(p, minlevel, maxlevel)
                        #println("mutate the connection  i:",i,"  old_inputs:",old_c.interiors[level,index].inputs[i],"  new_inputs[i]:",new_inputs[i])
                    end
                else # don't mutate this gene
                    #println("don't mutate")
                    if i == 0
                        new_func = old_func
                    else
                        new_inputs[i] = old_c.interiors[level,index].inputs[i]
                    end
                end  # if genes_to_mutate_index >= . . .
                gene_index += 1
                #println("level:",level,"  index:",index,"  i:",i,"  gene_index:",gene_index,"  genes_to_mutate_index:",genes_to_mutate_index)
            end  # for i in 0:old_func.arity 
            new_c.interiors[level, index] = InteriorNode(new_func, new_inputs)
        end # for index =
    end # for level = 

    # Output nodes
    minlevel = max(p.numlevels - p.numlevelsback + 1, 0)
    maxlevel = p.numlevels
    for i = 1:numoutputs
        #println("output i:",i,"  gene_index:",gene_index,"  genes_to_mutate_index:",genes_to_mutate_index)
        if  genes_to_mutate_index <= length(genes_to_mutate) && gene_index == genes_to_mutate[genes_to_mutate_index]  # mutate 
            #println("mutate output node")
            genes_to_mutate_index += 1
            (level, index) = random_node_position(p, minlevel, maxlevel)
            #println("old: ",old_c.outputs[i].input,"  new:",(level,index)) 
            new_c.outputs[i] = OutputNode((level, index))
            new_c[level, index].active = false
        else
            new_c.outputs[i] = old_c.outputs[i]
        end
        gene_index += 1
    end # for i =
    return new_c
end

#=
function default_parameters()
    mu = 1
    lambda = 4
    numperlevel = 2
    numlevels = 8
    numlevelsback = 8
    numinputs = 3
    numoutputs = 2
    mutrate = 0.3
    targetfitness = 1.0
    funcs = [AND, OR, XOR, NOT, ONE, ZERO ]
    fitfunc = hamming_max

    #p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)

    p =  Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numperlevel, numlevels, numlevelsback, funcs, fitfunc)
    return p
end


function chromosome_half_adder(numperlevel=1, numlevels=2, numlevelsback=2)
    numinputs = 2
    numoutputs = 2

    #p = Parameters(numinputs, numoutputs, numperlevel, numlevels, numlevelsback)
    p = default_parameters()
    c = Chromosome(p)

    c.inputs = [InputNode(1), InputNode(2)]
    c.interiors = Array(InteriorNode,2,1)
    c.interiors[1,1] = InteriorNode(XOR, [(0, 1), (0, 2)])
    c.interiors[2,1] = InteriorNode(AND, [(0, 1), (0, 2)])
    c.outputs = [OutputNode((1, 1)), OutputNode((2, 1))]

    return c
end

function goal_half_adder()
    g = Goal(2, (0b0110, 0b1000))
    return g
end

num_iter = 20
rlist = [rand(1:1000) for i in 1:num_iter]
for i in 1:num_iter
    r = rlist[i]
    println("r:",r)
    srand(r)
    #c0 = chromosome_half_addder()
    c0 = random_chromosome(default_parameters())
    cm0 = mutate(c0)
    print_chromosome(c0)
    print_chromosome(cm0)
end
=#
