export NodePosition, Node, InputNode, InteriorNode, OutputNode

using Compat

typealias NodePosition @compat Tuple{Integer, Integer}

abstract Node

type InputNode <: Node
    index::Integer
    active::Bool
end

function InputNode(index::Integer)
    return InputNode(index, false)
end

type InteriorNode <: Node
    func::Func
    inputs::Vector{NodePosition}
    active::Bool
end

function InteriorNode(func::Func, inputs::Vector{NodePosition})
    return InteriorNode(func, inputs, false)
end

type OutputNode <: Node
    input::NodePosition
end
