import Base.getindex

export ChromosomeCache, getindex

type ChromosomeCache
    params::Parameters
    inputs::Vector{InputNodeCache}
    interiors::Matrix{InteriorNodeCache}
    outputs::Vector{OuputNodeCache}
end

function ChromosomeCache(p::Parameters)
    inputs = Array(InputNodeCache, p.numinputs)
    interiors = Array(InteriorNodeCache, p.numlevels, p.numperlevel)
    outputs = Array(OutputNodeCache, p.numoutputs)

    return ChromosomeCache(p, inputs, interiors, outputs)
end

function getindex(c::ChromosomeCache, level::Integer, index::Integer)
    if level == 0
        return c.inputs[index]
    end

    if level > c.params.numlevels
        return c.outputs[index]
    end

    return c.interiors[level, index]
end


