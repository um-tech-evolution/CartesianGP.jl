import Base.call

export Circuit

abstract Circuit{I,O}

immutable BasicCircuit{I,O} <: Circuit{I,O}
  params::Parameters
  nodes::Vector{Node}
  outputs::Vector{NodeIndex}
end

function call{I,O}(circuit::BasicCircuit{I,O}, ctx::Context)
  invalues = [b for b = ctx]
  for node = circuit.nodes
    invalues = [invalues; node(invalues)]
  end
  return invalues[circuit.outputs]
end

call{I,O}(circuit::BasicCircuit{I,O}) = circuit(stdctx())

