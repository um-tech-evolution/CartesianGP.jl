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

active(node::BasicNode) = node.active
active(node::BasicNode, a::Bool) = BasicNode(a, node.func, node.inputs)

func(node::BasicNode) = node.func
func(node::BasicNode, f::FuncIndex) = BasicNode(node.active, f, node.inputs)

inputs(node::BasicNode) = node.inputs
inputs(node::BasicNode, ns::NodeIndex...) = BasicNode(node.active, node.func, [n for n = ns])

