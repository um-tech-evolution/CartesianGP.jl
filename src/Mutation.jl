export mutate

function mutate(old_c::Chromosome, funcs::Vector{Func})
    p = old_c.params
    mutrate = p.mutrate
    numinputs = p.numinputs
    numoutputs = p.numoutputs

    new_c = Chromosome(p)

    # Input nodes
    for i = 1:numinputs
        new_c.inputs[i] = old_c.inputs[i]
    end

    # Interior nodes
    for level = 1:p.numlevels
        minlevel = max(level - p.numlevelsback, 0)
        maxlevel = level - 1
        for index = 1:p.numperlevel
            old_func = old_c[level, index].func

            # Default is to keep the old values
            new_func = old_func
            new_inputs = Array(NodePosition, new_func.arity)
            for i = 1:old_func.arity
                new_inputs[i] = old_c[level, index].inputs[i]
            end

            if rand() <= mutrate
                # Mutate the gene
                mut_choice = rand(0:old_func.arity)
                if mut_choice == 0
                    # Mutate the function
                    valid_funcs = filter((f) -> f.arity == old_func.arity, funcs)
                    new_func = valid_funcs[rand(1:end)]
                else
                    # Mutate a connection
                    new_inputs[mut_choice] = random_node_position(p, minlevel, maxlevel)
                end
            end

            # Set inputs to active
            for (input_level, input_index) = new_inputs
                new_c[input_level, input_index].active = true
            end

            new_c.interiors[level, index] = InteriorNode(new_func, new_inputs)
        end
    end

    # Output nodes
    minlevel = max(p.numlevels - p.numlevelsback + 1, 0)
    maxlevel = p.numlevels
    for i = 1:numoutputs
        new_c.outputs[i] = old_c.outputs[i]
        if rand() <= mutrate
            (level, index) = random_node_position(p, minlevel, maxlevel)
        else
            (level, index) = new_c.outputs[i].input
        end
        new_c.outputs[i] = OutputNode((level, index))
        new_c[level, index].active = true
    end

    return new_c
end
