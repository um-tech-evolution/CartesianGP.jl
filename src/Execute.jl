export execute_chromosome

import CGP.output_mask
import CGP.std_input_context

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

# Executes chrososome using the standard input context
function execute_chromosome(c::Chromosome)
    params = c.params
    mask = output_mask(params.numinputs)

    ctx = std_input_context(params.numinputs)
    result = execute_chromosome(c, std_input_context(params.numinputs))

    return BitString[x & mask for x = result]
end
