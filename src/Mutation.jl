export random_mutation

function mutate(old_c::Chromosome)
    p = old_c.params
    mutrate = p.mutrate

    new_c = Chromosome(p)

    for index = 1:length(new_c.inputs)
        new_c.inputs[index] = InputNode(index)
    end

    for level = 1:p.numlevels
        minlevel = max(level - p.numlevelsback, 0)
        maxlevel = level - 1
        for index = 1:p.numperlevel
            inputs = Array(NodePosition, func.arity)
            if rand() <= mutrate
                func = funcs[rand(1:end)]
                for i = 1:func.arity
                    (input_level, input_index) = random_node_position(p, minlevel, maxlevel)
                    inputs[i] = (input_level, input_index)
                    new_c[input_level, input_index].active = true
                end
            else
                func = old_c.interiors[level, index].func
                for i = 1:func.arity
                    (input_level, input_index) = old_c.interiors[level, index].inputs[i]
                    inputs[i] = (input_level, input_index)
                    new_c[input_level, input_index].active = true
                end
            end
            new_c.interiors[level, index] = InteriorNode(func, inputs)
        end
    end

    minlevel = p.numlevels - p.numlevelsback + 1
    maxlevel = p.numlevels
    for i = 1:length(c.outputs)
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
