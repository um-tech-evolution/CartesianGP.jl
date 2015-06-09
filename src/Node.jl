export NodePosition, Node, InputNode, InteriorNode, OutputNode

using Compat

typealias NodePosition @compat Tuple{Int, Int}

abstract Node

type InputNode <: Node
    index::Integer
end

type InteriorNode <: Node
    func::Func
    inputs::Vector{NodePosition}
end

type OutputNode <: Node
    input::NodePosition
end
