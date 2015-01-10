module CGP

export Func, default_funcs, Parameters, default_parameters, InputNode, InteriorNode, blank_chromosome, random_chromosome

type Func
    func::Function
    maxinputs::Integer
end

function default_funcs()
    return [Func(+, 2), Func(-, 2)]
end

immutable Parameters
    mu::Integer
    lambda::Integer
    mutrate::FloatingPoint
    targetfitness::FloatingPoint

    numinputs::Integer
    numoutputs::Integer
    numnodes::Integer
    nodearity::Integer

    numlevels::Integer
    levelsback::Integer
end

function default_parameters(numinputs, numoutputs, numnodes, nodearity, numlevels, levelsback)
    mu = 1
    lambda = 4
    mutrate = 0.05
    targetfitness = 0.0

    return Parameters(mu, lambda, mutrate, targetfitness, numinputs, numoutputs, numnodes, nodearity, numlevels, levelsback)
end

abstract Node

type InputNode <: Node
    index::Integer
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
    perlevel = (p.numnodes / p.numlevels)
    func = funcs[rand(1:end)]
    level = div(index - 1, perlevel) + 1
    firstlevel = max(level - p.levelsback, 0)
    start = ifelse(firstlevel == 0, -p.numinputs + 1, (firstlevel - 1) * perlevel + 1)
    stop = (level - 1) * perlevel
    
    nodeinputs = Array(Node, p.nodearity)
    for i = 1:length(nodeinputs)
        src = rand(start:stop)
        if src < 1
            # Chose an input
            nodeinputs[i] = chrom.inputs[-src + 1]
        else
            nodeinputs[i] = chrom.nodes[src]
        end
    end

    # Defaults
    active = true

    return InteriorNode(func, nodeinputs, active)
end

function random_output(p::Parameters, nodes::Vector{InteriorNode})
end

function blank_chromosome(p::Parameters)
    inputs = Array(InputNode, p.numinputs)
    nodes = Array(InteriorNode, p.numnodes)
    outputs = Array(OutputNode, p.numoutputs)
    fitness = 0.0
    return Chromosome(inputs, nodes, outputs, fitness)
end

function random_chromosome(p::Parameters, funcs::Vector{Func})
    chromosome = blank_chromosome(p)

    for i = 1:length(chromosome.inputs)
        chromosome.inputs[i] = InputNode(i)
    end

    for i = 1:length(chromosome.nodes)
        chromosome.nodes[i] = random_node(p, funcs, chromosome, i)
    end

    return chromosome
end

function evaluate_node(node::InputNode, context::Vector{Integer})
    return context[node.index]
end

function evaluate_node(node::InteriorNode, context::Vector{Integer})
    func = node.func
    return apply(func.func, [evaluate_node(n) for n = node.inputs[1:func.maxinputs]])
end

function evaluate_node(node::OutputNode, context::Vector{Integer})
    return evaluate_node(node.input, context)
end

function execute_chromosome(chromosome::Chromosome, context::Vector{Integer})
    return [evaluate_node(n, context) for n = chromosome.outputs]
end

end
