export execute_chromosome

function evaluate_node(c::Chromosome, node::InputNode, context::Vector{BitString})
    return context[node.index]
end

function evaluate_node(c::Chromosome, node::InteriorNode, context::Vector{BitString})
    func = node.func
    args = map(node.inputs[1:func.arity]) do position
        (level, index) = position
        evaluate_node(c, c[level, index], context)
    end
    return apply(func.func, args)
end

function evaluate_node(c::Chromosome, node::OutputNode, context::Vector{BitString})
    (level, index) = node.input
    return evaluate_node(c, c[level, index], context)
end

function execute_chromosome(c::Chromosome, context::Vector{BitString})
    return BitString[evaluate_node(c, node, context) for node = c.outputs]
end
