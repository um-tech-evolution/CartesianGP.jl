export execute_chromosome_cache, get_number_active_nodes

function evaluate_node_cache(c::Chromosome, node::InputNode, cnode::InputNodeCache, context::Vector{BitString})
    if ! cnode.active
        cnode.active = true
        #c.number_active_nodes += 1  # do not remove:  I want to add this back in later
    end
    return context[node.index]
end

function evaluate_node_cache(c::Chromosome, node::InteriorNode, cnode::InteriorNodeCache, context::Vector{BitString})
    if ! cnode.active
        func = node.func
        args = map(node.inputs[1:func.arity]) do position
            (level, index) = position
            evaluate_node_cache(c, c[level, index], c.cache[level,index], context)
        end
        cnode.active = true
        cnode.cache = func.func(args...)
        #c.number_active_nodes += 1
    end
    return cnode.cache
end

function evaluate_node_cache(c::Chromosome, node::OutputNode, cnode::OutputNodeCache, context::Vector{BitString})
    if ! cnode.active
        cnode.active = true
        (level, index) = node.input
        cnode.cache = evaluate_node_cache(c, c[level, index], c.cache[level,index], context)
        #c.number_active_nodes += 1
    end
    return cnode.cache
end

# TODO: Since we are caching the evaluation results we should no
# longer expose the context since providing two different contexts for
# the same chromosome will produce incorrect results the second time
# around.

function execute_chromosome_cache(c::Chromosome, context::Vector{BitString})
    if ! c.has_cache
        c.cache = ChromosomeCache(c.params,true)
        c.has_cache = true
        println("cache: ",c.cache)
    end
    return BitString[evaluate_node_cache(c, c.outputs[i], c.cache.outputs[i], context) 
              for i = 1:length(c.outputs)]
end

# Executes chrososome using the standard input context
function execute_chromosome_cache(c::Chromosome)
    params = c.params
    mask = output_mask(params.numinputs)

    ctx = std_input_context(params.numinputs)
    result = execute_chromosome_cache(c, ctx)

    return BitString[x & mask for x = result]
end

