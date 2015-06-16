import Base.getindex

export ChromosomeCache, getindex

type ChromosomeCache
    params::Parameters
    inputs::Vector{InputNodeCache}
    interiors::Matrix{InteriorNodeCache}
    outputs::Vector{OutputNodeCache}
    number_active_nodes::Int
end

function ChromosomeCache(p::Parameters, fill::Bool = false )
    number_active_nodes = 0
    interiors = Array(InteriorNodeCache, p.numlevels, p.numperlevel)
    if fill
        inputs = [ InputNodeCache() for i in 1:p.numinputs ]
        outputs = [ OutputNodeCache() for i in 1:p.numoutputs ]
        for i in 1:p.numlevels
            for j in 1:p.numperlevel
                interiors[i,j] = InteriorNodeCache()
            end
        end
    else
        inputs = Array(InputNodeCache, p.numinputs)
        outputs = Array(OutputNodeCache, p.numoutputs)
    end

    return ChromosomeCache(p, inputs, interiors, outputs, number_active_nodes )
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


