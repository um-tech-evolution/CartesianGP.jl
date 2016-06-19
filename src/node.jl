import Base.rand, Base.call

export Node, BasicNode

# TODO: Input count should be fixed, where does it come from?
# TODO: Should we validate the node indices at all?
# TODO: Document the Node interface.

typealias NodeIndex Int

@doc """A circuit node.
"""
abstract Node

@doc """A standard, immutable circuit node.

  * `params` - a `Parameters` instance to control the node
  * `active` - whether this node participates in its circuit (unused)
  * `fun` - the function applied by this node
  * `inputs` - indexes used as inputs to the node's function
"""
immutable BasicNode <: Node
  params::Parameters
  active::Bool
  fun::Fun
  inputs::Vector{NodeIndex}
end

BasicNode(p::Parameters, f::Fun, ns::NodeIndex...) = BasicNode(p, f, [n for n = ns])

# -----------------------------
# Node interface implementation
# -----------------------------

function call(node::BasicNode, predacessors::Vector{BitString})
  invalues = predacessors[node.inputs]
  return node.fun(invalues...)
end

setactive(node::BasicNode, a::Bool) = BasicNode(node.params, a, node.func, node.inputs)
setfun(node::BasicNode, f::Fun) = BasicNode(node.params, node.active, f, node.inputs)
setinputs(node::BasicNode, ns::NodeIndex...) = BasicNode(node.params, node.active, node.func, [n for n = ns])

