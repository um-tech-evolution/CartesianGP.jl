import Base.rand

export Node, BasicNode

# TODO: Input count should be fixed, where does it come from?
# TODO: Should we validate the node indices at all?
# TODO: Document the Node interface.

typealias NodeIndex Int
typealias FuncIndex Int

@doc """A circuit node.
"""
abstract Node

@doc """A standard, immutable circuit node.
"""
immutable BasicNode <: Node
  active::Bool
  func::FuncIndex
  inputs::Vector{NodeIndex}
end

BasicNode(f::FuncIndex, ns::NodeIndex...) = BasicNode(f, [n for n = ns])

# -----------------------------
# Node interface implementation
# -----------------------------

setactive(node::BasicNode, a::Bool) = BasicNode(a, node.func, node.inputs)

setfunc(node::BasicNode, f::FuncIndex) = BasicNode(node.active, f, node.inputs)

setinputs(node::BasicNode, ns::NodeIndex...) = BasicNode(node.active, node.func, [n for n = ns])

