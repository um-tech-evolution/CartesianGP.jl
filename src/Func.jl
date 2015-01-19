export Func, default_funcs

type Func
    func::Function
    arity::Integer
end

const AND = Func(&, 2)
const OR = Func(|, 2)
const XOR = Func($, 2)
const TRUE = Func(() -> 0xf, 0)

function default_funcs()
    return [AND, OR, XOR, TRUE]
end

