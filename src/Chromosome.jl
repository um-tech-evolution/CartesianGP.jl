import Base.getindex

export Chromosome, getindex, print_chromosome

type Chromosome
    params::Parameters
    inputs::Vector{InputNode}
    interiors::Matrix{InteriorNode}
    outputs::Vector{OutputNode}
    fitness::FloatingPoint
end

function Chromosome(p::Parameters)
    inputs = Array(InputNode, p.numinputs)
    interiors = Array(InteriorNode, p.numlevels, p.numperlevel)
    outputs = Array(OutputNode, p.numoutputs)
    fitness = 0.0
    return Chromosome(p, inputs, interiors, outputs, fitness)
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
        active = c.outputs[i].active ? "+" : "*"
        if c.outputs[i].active || !active_only
            print("[",c.outputs[i].input,"out",i,active,"] ")
        end
    end
    println()
    return
end
