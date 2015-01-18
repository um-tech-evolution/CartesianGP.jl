export Func, default_funcs

type Func
    func::Function
    arity::Integer
end

function default_funcs()
    return [Func(&, 2), Func(|, 2)]
end

