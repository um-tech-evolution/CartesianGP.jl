export mutate

# This version added for compatibility, the mutation rate and the
# functions are taken from the parameters which are passed as a
# component of the chromosome.
function mutate(old_c::Chromosome)
    return mutate(old_c, old_c.params.funcs)
end

# Mutate Chromosome old_c.
function mutate(old_c::Chromosome, funcs::Vector{Func} )
    p = old_c.params
    mutrate = p.mutrate
    numinputs = p.numinputs
    numoutputs = p.numoutputs

    # Count number of genes
    num_genes = numoutputs # one connection per output gene
    for level = 1:p.numlevels
        for index = 1:p.numperlevel
            num_genes += 1+old_c.interiors[level,index].func.arity
        end
    end

    # Determine number of mutations, but make sure that it is always at least 1
    num_mutations = max(1,convert(Int,floor(num_genes*mutrate))) # doesn't seem right, but what CGP version 1.1 does)
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

    # Input nodes
    for i = 1:numinputs
        new_c.inputs[i] = old_c.inputs[i]
    end

    gene_index = 1
    genes_to_mutate_index = 1
    # Interior nodes
    new_c.interiors =  Array(InteriorNode, p.numlevels, p.numperlevel) # Always use a new array 
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
                continue
            end   
            new_inputs = Array(NodePosition, old_func.arity)
            new_func = old_func
            for i in 0:old_func.arity # iterate through the genes in this node with 0 corresponding to the function
                if genes_to_mutate_index <= length(genes_to_mutate) && gene_index == genes_to_mutate[genes_to_mutate_index]  # mutate 
                    genes_to_mutate_index += 1
                    if i == 0    # mutate the function
                        new_func = funcs[rand(1:end)]
                        if new_func.arity != old_func.arity # change in arity
                            new_inputs = Array(NodePosition, new_func.arity) # we must generate a new node with the new arity
                            for j = 1:new_func.arity   
                                if j <= old_func.arity
                                    new_inputs[j] = old_c[level, index].inputs[j]
                                else
                                    new_inputs[j] = random_node_position(p, minlevel, maxlevel)
                                end
                            end
                            gene_index += 1+old_func.arity # skip over mutating inputs
                            # skip over mutating inputs
                            while genes_to_mutate_index <= length(genes_to_mutate) &&  genes_to_mutate[genes_to_mutate_index] < gene_index  
                                genes_to_mutate_index += 1
                            end
                            break # break out of for i loop
                        end
                    else  # mutate the connection
                        new_inputs[i] = random_node_position(p, minlevel, maxlevel)
                    end
                else # don't mutate this gene
                    if i == 0
                        new_func = old_func
                    else
                        new_inputs[i] = old_c.interiors[level,index].inputs[i]
                    end
                end # if genes_to_mutate_index >= . . .
                gene_index += 1
            end # for i in 0:old_func.arity 
            new_c.interiors[level, index] = InteriorNode(new_func, new_inputs)
        end # for index =
    end # for level = 

    # Output nodes
    minlevel = max(p.numlevels - p.numlevelsback + 1, 0)
    maxlevel = p.numlevels
    for i = 1:numoutputs
        if  genes_to_mutate_index <= length(genes_to_mutate) && gene_index == genes_to_mutate[genes_to_mutate_index]  # mutate 
            genes_to_mutate_index += 1
            (level, index) = random_node_position(p, minlevel, maxlevel)
            new_c.outputs[i] = OutputNode((level, index))
            new_c[level, index].active = false
        else
            new_c.outputs[i] = old_c.outputs[i]
        end
        gene_index += 1
    end # for i =
    return new_c
end
