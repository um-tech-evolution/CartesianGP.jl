export Fun

immutable Fun{A}
  fun::Function
  name::AbstractString
end

Fun(f::Function, a::Integer, name::AbstractString) = Fun{a}(f, name)
Fun(f::Function, a::Integer) = Fun(f, a, string(f))

const AND = Fun(&, 2)
const OR = Fun(|, 2)
const XOR = Fun($, 2)
const NAND = Fun((x,y) -> ~(x & y),2,"^&")
const NOR = Fun((x,y) -> ~(x | y),2,"^|")
const NOT = Fun(~, 1)
const ZERO = Fun(() -> convert(BitString, 0), 0, "0")
const ONE = Fun(() -> ~convert(BitString, 0), 0, "1")

const DEFAULT_FUNCS = [AND, OR, XOR, NOT, ZERO, ONE]

