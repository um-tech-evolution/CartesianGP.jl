export execute_chromosome

function evaluate_node(c::Chromosome, node::InputNode, context::Vector{BitString})
    return context[node.index]
end

function evaluate_node(c::Chromosome, node::InputNode, cache_node::InputNodeCache, context::Vector{BitString})
    if ! cache_node.active
        cache_node.active = true
        c.cache.number_active_nodes += 1
    end
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

function evaluate_node(c::Chromosome, node::InteriorNode, cache_node::InteriorNodeCache, context::Vector{BitString})
    if ! cache_node.active
        func = node.func
        args = map(node.inputs[1:func.arity]) do position
            (level, index) = position
            evaluate_node(c, c[level, index], c.cache[level,index], context)
        end
        cache_node.active = true
        cache_node.cache = func.func(args...)
        c.cache.number_active_nodes += 1
    end
    return cache_node.cache
end

function evaluate_node(c::Chromosome, node::OutputNode, context::Vector{BitString})
    (level, index) = node.input

    return evaluate_node(c, c[level, index], context)
end

function evaluate_node(c::Chromosome, node::OutputNode, cache_node::OutputNodeCache, context::Vector{BitString})
    if ! cache_node.active
        cache_node.active = true
        (level, index) = node.input
        cache_node.cache = evaluate_node(c, c[level, index], c.cache[level,index], context)
        c.cache.number_active_nodes += 1
    end
    return cache_node.cache
end

# TODO: Since we are caching the evaluation results we should no
# longer expose the context since providing two different contexts for
# the same chromosome will produce incorrect results the second time
# around.

function execute_chromosome(c::Chromosome, context::Vector{BitString})
    if c.has_cache
        return BitString[evaluate_node(c, c.outputs[i], c.cache.outputs[i], context) for i in 1:length(c.outputs)]
    else
        return BitString[evaluate_node(c, node, context) for node = c.outputs]
    end
end

# Executes chrososome using the standard input context
function execute_chromosome(c::Chromosome)
    params = c.params
    mask = output_mask(params.numinputs)

    ctx = std_input_context(params.numinputs)
    result = execute_chromosome(c, ctx)

    return BitString[x & mask for x = result]
end
