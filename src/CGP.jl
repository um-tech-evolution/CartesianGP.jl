module CGP

include("Func.jl")
include("Parameters.jl")

export InputNode, InteriorNode, blank_chromosome, random_chromosome, execute_chromosome

abstract Node

type InputNode <: Node
    index::Integer
    active::Bool
end

type InteriorNode <: Node
    func::Func
    inputs::Vector{Node}
    active::Bool
end

type OutputNode <: Node
    input::Union(InputNode, InteriorNode)
end

type Chromosome
    inputs::Vector{InputNode}
    nodes::Vector{InteriorNode}
    outputs::Vector{OutputNode}
    fitness::FloatingPoint
end

function random_node(p::Parameters, funcs::Vector{Func}, chrom::Chromosome, index::Integer)
    func = funcs[rand(1:end)]
    level = div(index - 1, p.numperlevel) + 1
    firstlevel = max(level - p.numlevelsback, 0)
    start = ifelse(firstlevel == 0, -p.numinputs + 1, (firstlevel - 1) * p.numperlevel + 1)
    stop = (level - 1) * p.numperlevel
    
    nodeinputs = Array(Node, p.nodearity)
    for i = 1:length(nodeinputs)
        src = rand(start:stop)
        if src < 1
            # Chose an input
            nodeinputs[i] = chrom.inputs[-src + 1]
        else
            nodeinputs[i] = chrom.nodes[src]
        end
        nodeinputs[i].active = true
    end

    # Defaults
    active = false

    return InteriorNode(func, nodeinputs, active)
end

function random_output(p::Parameters, chrom::Chromosome)
    level = p.numlevels + 1
    firstlevel = max(p.numlevels - p.numlevelsback, 0)
    start = ifelse(firstlevel == 0, -p.numinputs + 1, (firstlevel - 1) * p.numperlevel + 1)
    stop = (level - 1) * p.numperlevel

    src = rand(start:stop)
    if src < 1
        # Chose an input
        input = chrom.inputs[-src + 1]
    else
        input = chrom.nodes[src]
    end
    input.active = true

    return OutputNode(input)
end

function blank_chromosome(p::Parameters)
    inputs = Array(InputNode, p.numinputs)
    nodes = Array(InteriorNode, p.numperlevel * p.numlevels)
    outputs = Array(OutputNode, p.numoutputs)
    fitness = 0.0
    return Chromosome(inputs, nodes, outputs, fitness)
end

function random_chromosome(p::Parameters, funcs::Vector{Func})
    chromosome = blank_chromosome(p)

    for i = 1:length(chromosome.inputs)
        chromosome.inputs[i] = InputNode(i, false)
    end

    for i = 1:length(chromosome.nodes)
        chromosome.nodes[i] = random_node(p, funcs, chromosome, i)
    end

    for i = 1:length(chromosome.outputs)
        chromosome.outputs[i] = random_output(p, chromosome)
    end

    return chromosome
end

function evaluate_node(node::InputNode, context::Vector)
    return context[node.index]
end

function evaluate_node(node::InteriorNode, context::Vector)
    func = node.func
    return apply(func.func, [evaluate_node(n, context) for n = node.inputs[1:func.arity]])
end

function evaluate_node(node::OutputNode, context::Vector)
    return evaluate_node(node.input, context)
end

function execute_chromosome(chromosome::Chromosome, context::Vector)
    return [evaluate_node(n, context) for n = chromosome.outputs]
end

end
