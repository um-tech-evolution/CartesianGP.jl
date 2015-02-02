import Base.getindex

export Chromosome, getindex, print_chromosome, random_chromosome

type Chromosome
    params::Parameters
    inputs::Vector{InputNode}
    interiors::Matrix{InteriorNode}
    outputs::Vector{OutputNode}
    active_set::Bool
    #fitness::FloatingPoint
end

function Chromosome(p::Parameters)
    inputs = Array(InputNode, p.numinputs)
    interiors = Array(InteriorNode, p.numlevels, p.numperlevel)
    outputs = Array(OutputNode, p.numoutputs)
    fitness = 0.0
    active_not_set = false

    return Chromosome(p, inputs, interiors, outputs, active_not_set)
end

function getindex(c::Chromosome, level::Integer, index::Integer)
    if level == 0
        return c.inputs[index]
    end

    if level > c.params.numlevels
        return c.outputs[index]
    end

    return c.interiors[level, index]
end

# Prints the chromosome in a compact text format (on one line).
# Active notes are indicated with a "+" and inactive notes with a "*".
# If active_only is true, then only the active notes are shown.
function print_chromosome(c::Chromosome, active_only::Bool=false)
    for i = 1:length(c.inputs)
        active = c.inputs[i].active ? "+" : "*"
        if c.inputs[i].active || !active_only
            print("[in",i,active,"] ")
        end
    end

    for i = 1:c.params.numlevels
        for j = 1:c.params.numperlevel
           active = c.interiors[i,j].active ? "+" : "*"
           if c.interiors[i,j].active || !active_only
               print("[")
               for k = 1:length(c.interiors[i,j].inputs)
                   if c.interiors[i,j].inputs[k][1] == 0
                       print("(in", c.interiors[i,j].inputs[k][2],")")
                   else
                       print(c.interiors[i,j].inputs[k])
                   end
               end
               print("\"",c.interiors[i,j].func.name,"\"",(i,j),active,"] ")
           end
        end
    end

    for i = 1:length(c.outputs)
        active = "+"
        #active = c.outputs[i].active ? "+" : "*"
        #if c.outputs[i].active || !active_only
        print("[",c.outputs[i].input,"out",i,active,"] ")
        #end
    end
    println()
    return
end

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
                #c[input_level, input_index].active = true
            end
            c.interiors[level, index] = InteriorNode(func, inputs)
        end
    end

    minlevel = p.numlevels - p.numlevelsback + 1
    maxlevel = p.numlevels
    for i = 1:length(c.outputs)
        (level, index) = random_node_position(p, minlevel, maxlevel)
        c.outputs[i] = OutputNode((level, index))
        #c[level,index].active = true
    end
    return c
end
