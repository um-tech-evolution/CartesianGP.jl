export Circuit

abstract Circuit{I,O}

immutable BasicCircuit{I,O} <: Circuit{I,O}
  nodes::Vector{Node}
end


