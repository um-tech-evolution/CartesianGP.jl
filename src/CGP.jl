module CGP

include("Func.jl")
include("Parameters.jl")
include("Node.jl")
include("Chromosome.jl")
include("Execute.jl")

export random_chromosome, print_chromosome

function first_in_level(p::Parameters, level::Integer)
    if level == 0
        first = 1
    else
        first = p.numinputs + 1 + (level - 1) * p.numperlevel
    end
    return first
end

function last_in_level(p::Parameters, level::Integer)
    if level == 0
        last = p.numinputs
    else
        last = p.numinputs + level * p.numperlevel
    end
    return last
end

function random_node_position(p::Parameters, minlevel::Integer, maxlevel::Integer)
    first = first_in_level(p, minlevel)
    last = last_in_level(p, maxlevel)

    i = rand(first:last)
    
    if i <= p.numinputs
        level = 0
        index = i
    else
        level = div(i - p.numinputs - 1, p.numperlevel) + 1
        index = rem(i - p.numinputs - 1, p.numperlevel) + 1
    end

    return (level, index)
end

function random_chromosome(p::Parameters, funcs::Vector{Func})
    c = Chromosome(p)

    for index = 1:length(c.inputs)
        c.inputs[index] = InputNode(index)
    end

    for level = 1:p.numlevels
        minlevel = max(level - p.numlevelsback, 0)
        maxlevel = level - 1
        for index = 1:p.numperlevel
            func = funcs[rand(1:end)]
            inputs = Array(NodePosition, func.arity)
            for i = 1:func.arity
                (input_level, input_index) = random_node_position(p, minlevel, maxlevel)
                inputs[i] = (input_level, input_index)
                c[input_level, input_index].active = true
            end
            c.interiors[level, index] = InteriorNode(func, inputs)
        end
    end

    minlevel = p.numlevels - p.numlevelsback + 1
    maxlevel = p.numlevels
    for i = 1:length(c.outputs)
        (level, index) = random_node_position(p, minlevel, maxlevel)
        c.outputs[i] = OutputNode((level, index),true)
        c[level,index].active = true
    end
    return c
end

end
