export execute_chromosome, output_mask

function evaluate_node(c::Chromosome, node::InputNode, context::Vector{BitString})
    node.active = true
    return context[node.index]
end

function evaluate_node(c::Chromosome, node::InteriorNode, context::Vector{BitString})
    func = node.func
    args = map(node.inputs[1:func.arity]) do position
        (level, index) = position
        evaluate_node(c, c[level, index], context)
    end
    node.active = true
    return apply(func.func, args)
end

function evaluate_node(c::Chromosome, node::OutputNode, context::Vector{BitString})
    (level, index) = node.input
    return evaluate_node(c, c[level, index], context)
end

function execute_chromosome(c::Chromosome, context::Vector{BitString})
    c.active_set = true
    return BitString[evaluate_node(c, node, context) for node = c.outputs]
end

# Supplies the standard context for up to 4 inputs
function execute_chromosome(chromosome::Chromosome)
   mask = output_mask(chromosome.params.numinputs)
   if chromosome.params.numinputs == 2
       result = execute_chromosome(chromosome, [convert(BitString,0xC), convert(BitString,0xA)])
   elseif chromosome.params.numinputs == 3
       result = execute_chromosome(chromosome, [convert(BitString,0xF0),convert(BitString,0xCC), convert(BitString,0xAA)])
   elseif chromosome.params.numinputs == 4
       result = execute_chromosome(chromosome, [convert(BitString,0xFF00),convert(BitString,0xF0F0),
           convert(BitString,0xCCCC), convert(BitString,0xAAAA)])
   else
       println("Too many inputs in execute_chromosome")
   end
   for i in 1:chromosome.params.numoutputs
      result[i] = result[i] & mask
   end
   return result
end

# bitstring mask for one output of the packed representation
function output_mask(num_inputs)
   one = convert(BitString,0x1)
   mask = one
   for i in 1:(2^num_inputs-1)
      mask <<= 1
      mask |= one
   end
   return mask
end

