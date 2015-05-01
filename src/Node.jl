export NodePosition, Node, InputNode, InteriorNode, OutputNode

using Compat

typealias NodePosition{T<:Integer} @compat Tuple{T, T}

abstract Node

type InputNode <: Node
    index::Integer
    active::Bool
end

InputNode(index::Integer) = InputNode(index, false)

type InteriorNode <: Node
    func::Func
    inputs::Vector{NodePosition}
    active::Bool
    cache::BitString
end

InteriorNode(func::Func, inputs::Vector{NodePosition}) = InteriorNode(func, inputs, false, convert(BitString, 0))

type OutputNode <: Node
    input::NodePosition
    active::Bool
    cache::BitString
end

OutputNode(input::NodePosition) = OutputNode(input, false, convert(BitString, 0))
