import Base.call

export Circuit

abstract Circuit{I,O}

immutable BasicCircuit{I,O} <: Circuit{I,O}
  params::Parameters
  nodes::Vector{Node}
end

function call(c::BasicCircuit)
  for node = c.nodes
  end
end

