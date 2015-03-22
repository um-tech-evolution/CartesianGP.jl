export execute_chromosome

function evaluate_node(c::Chromosome, node::InputNode, context::Vector{BitString})
    node.active = true
    return context[node.index]
end

function evaluate_node(c::Chromosome, node::InteriorNode, context::Vector{BitString})
    if ! node.active
        func = node.func
        args = map(node.inputs[1:func.arity]) do position
            (level, index) = position
            evaluate_node(c, c[level, index], context)
        end
        node.active = true
        node.cache = func.func(args...)
    end
    return node.cache
end

function evaluate_node(c::Chromosome, node::OutputNode, context::Vector{BitString})
    if ! node.active
        node.active = true
        (level, index) = node.input
        node.cache = evaluate_node(c, c[level, index], context)
    end
    return node.cache
end

# TODO: Since we are caching the evaluation results we should no
# longer expose the context since providing two different contexts for
# the same chromosome will produce incorrect results the second time
# around.

function execute_chromosome(c::Chromosome, context::Vector{BitString})
    c.active_set = true
    return BitString[evaluate_node(c, node, context) for node = c.outputs]
end

# Supplies the standard context for up to 4 inputs
function execute_chromosome(c::Chromosome)
    params = c.params
    mask = output_mask(params.numinputs)

    if params.numinputs == 1
        ctx = [0b10]
    elseif params.numinputs == 2
        ctx = [0b1100, 0b1010]
    elseif params.numinputs == 3
        ctx = [0b11110000, 0b11001100, 0b10101010]
    elseif params.numinputs == 4
        ctx = [0b1111111100000000, 0b1111000011110000, 0b1100110011001100, 0b1010101010101010]
    else
        error("Too many inputs, max is 4")
    end

    result = execute_chromosome(c, BitString[x for x = ctx])

    return BitString[x & mask for x = result]
end
