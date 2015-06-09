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

    return func.func(args...)
end

function evaluate_node(c::Chromosome, node::OutputNode, context::Vector{BitString})
    (level, index) = node.input

    return evaluate_node(c, c[level, index], context)
end

# TODO: Since we are caching the evaluation results we should no
# longer expose the context since providing two different contexts for
# the same chromosome will produce incorrect results the second time
# around.

function execute_chromosome(c::Chromosome, context::Vector{BitString})
    return BitString[evaluate_node(c, node, context) for node = c.outputs]
end

# Executes chrososome using the standard input context
function execute_chromosome(c::Chromosome)
    params = c.params
    mask = output_mask(params.numinputs)

    ctx = std_input_context(params.numinputs)
    result = execute_chromosome(c, ctx)

    return BitString[x & mask for x = result]
end
