export Func, default_funcs, AND, OR, XOR, NAND, NOR, NOT, ZERO, ONE

type Func
    func::Function
    arity::Integer
    name::AbstractString
end

Func(f::Function, a::Integer) = Func(f, a, string(f))

const AND = Func(&, 2)
const OR = Func(|, 2)
const XOR = Func($, 2)
const NAND = Func((x,y)->~(x & y),2,"^&")
const NOR = Func((x,y)->~(x | y),2,"^|")
const NOT = Func(~, 1)
const ZERO = Func(() -> convert(BitString, 0), 0, "0")
const ONE = Func(() -> ~convert(BitString, 0), 0, "1")

function default_funcs()
    return [AND, OR, XOR, NOT, ZERO, ONE]
end

