module CGP

type Func
    func::Function
    maxinputs::Integer
end

type Node
    func::Integer
    inputs::Vector{Integer}
    active::Bool
    output::Uint64
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

type Chromosome
    nodes::Vector{Node}
    fitness::FloatingPoint
end

function random_node(p::Parameters, funcs::Vector{Func}, index::Integer)
    perlevel = (p.numnodes / p.numlevels)
    func = rand(1:funcs)
    level = div(index - 1, perlevel) + 1
    inputs = map(1:p.nodearity) do j
        if level == 1
            # First level, choose from inputs
            rand(1:p.numinputs)::Integer
        else
            start = (level - 1 - p.levelsback) * perlevel + 1
            stop = (level - 1) * perlevel
            rand(start:stop)::Integer
        end
    end

    # Defaults
    active = true
    output = 0

    return Node(func, inputs, active, output)
end

function blank_chromosome(p::Parameters)
    nodes = Vector(Node, p.numnodes)
    fitness = 0.0
    return Chromosome(nodes, fitness)
end

function random_chromosome(p::Parameters, funcs::Vector{Func})
    chromosome = blank_chromosome(p)
    nodes = map(i -> random_node(p, funcs, i), 1:p.numnodes)
    chromosome.nodes = nodes
end

