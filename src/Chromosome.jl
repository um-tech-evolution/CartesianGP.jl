import Base.getindex

export Chromosome, getindex

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
