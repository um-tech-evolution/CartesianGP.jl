import Base.==
import Base.convert

export Goal, PackedGoal, BasicPackedGoal, InterleavedPackedGoal, print_goal, convert, ==

# A goal describes a boolean function with one or more inputs and one or more
# outputs. It defines the number of inputs and the values of each output for
# all possible input combinations.
immutable Goal{N}
    num_inputs::Integer
    truth_table::NTuple{N, BitString}
end

Goal{N}(n::Integer, t::NTuple{N, Integer}) = Goal(n, convert(NTuple{N, BitString}, t))
Goal{N}(n::Integer, b::Vector{BitString}) = Goal(n, ntuple(i -> b[i], length(b)))
Goal{N}(c::Chromosome, b::Vector{BitString}) = Goal(c.num_inputs, b)

# The equality operator for Goals is true if the number of inputs, number of
# outputs, and the output truth tables are identical and false otherwise.
=={N}(g::Goal{N}, h::Goal{N}) = (g.num_inputs == h.num_inputs) && (g.truth_table == h.truth_table)
=={G, H}(g::Goal{G}, h::Goal{H}) = false

# Prints a goal in hex format. The truth table entries are printed from highest
# to lowest index. In other words: `print_goal(Goal(1, (0x8, 0x6)))` will
# print "(1, 2, [0x6, 0x8])".
function print_goal{N}(g::Goal{N})
    @printf("(%d, %d, [", g.num_inputs, N)
    for i in N:-1:2
        @printf("%#x ",g.truth_table[i])
    end
    @printf("%#x])\n",g.truth_table[1])
end

# Goals can have multiple outputs.
# There are three formats for goals:
# unpacked:  each output is stored in a separate BitString (this is the output format of execute chromosome)
# packed (also called non-interleved):  All outputs are stored in one BitString.
#      All bits of an output are consecutive.
# interleaved:  All outputs are stored in one BitString.
#      The bits of outputs are interleaved.  This format is used by the g_compose f function.

# GoalPacked is a goal type where all outputs are "packed" into one BitString.
# May be non-interleaved or interleaved.
# The interleaved field should be true if interleaved, false if non-interleaved.

# Packed goals combine all outputs into a single bitstring and, consequently,
# can only handle functions with an appropriately small number of outputs.
abstract PackedGoal

immutable BasicPackedGoal <: PackedGoal
    num_inputs::Integer
    num_outputs::Integer
    truth_table::BitString
end

immutable InterleavedPackedGoal <: PackedGoal
    num_inputs::Integer
    num_outputs::Integer
    truth_table::BitString
end

function =={T <: PackedGoal}(g::T, h::T)
    (g.num_inputs == h.num_inputs) &&
    (g.num_outputs == h.num_outputs) &&
    (g.truth_table == h.truth_table)
end
==(g::BasicPackedGoal, h::InterleavedPackedGoal) = error("Cannot compare basic and interleaved goals")
==(g::InterleavedPackedGoal, h::BasicPackedGoal) = h == g

# TODO: Do we need a type parameter here? Probably? Maybe?
function convert(::Type{Goal}, g::BasicPackedGoal)
    temp_ttable = g.truth_table
    ttable = Array(BitString, g.num_outputs)
    mask = output_mask(g.num_inputs)
    for i = 1:g.num_outputs
        ttable[i] = mask & temp_ttable
        temp_ttable >>= (2 ^ g.num_inputs)
    end
    return Goal(g.num_inputs, ttable)
end

function convert{N}(::Type{BasicPackedGoal}, g::Goal{N})
    if (2 ^ g.num_inputs) * N > sizeof(BitString)
        error("The goal is too large to be packed.")
    end

    ttable = g.truth_table[N]
    for i = (N-1):-1:1
        ttable <<= (2 ^ g.num_inputs)
        ttable $= g.truth_table[i]
    end
    return BasicPackedGoal(g.num_inputs, N, ttable)
end

function convert(::Type{InterleavedPackedGoal}, g::BasicPackedGoal)
    ttable = convert(BitString, 0)
    one = convert(BitString, 1)
    p = 2 ^ g.num_inputs
    for j = (p-1):-1:0
        for k = N:-1:0
            r = g.truth_table >> (k * (p - 1) + j + k)
            ttable = (ttable << 1) $ (r & one)
        end
    end
    return InterleavedPackedGoal(g.num_inputs, N, ttable)
end

function convert(::Type{BasicPackedGoal}, g::InterleavedPackedGoal)
    ttable = convert(BitString,0)
    one = convert(BitString, 1)
    p = 2 ^ g.num_inputs
    for j in g.num_outputs-1:-1:0
        for k in p-1:-1:0
            r = in >> (k * g.num_outputs + j)
            ttable = (ttable << 1) $ (r & one)
        end
    end
    return BasicPackedGoal(g.num_inputs, g.num_outputs, ttable)
end

function convert(::Type{Goal}, g::InterleavedPackedGoal)
    return convert(Goal, convert(BasicPackedGoal, g))
end

function convert{N}(::Type{InterleavedPackedGoal}, g::Goal{N})
    return convert(InterleavedPackedGoal, convert(BasicPackedGoal, g))
end

# Utility function which returns bitstring mask for one output of the packed representation.
function output_mask(num_inputs)
    one = convert(BitString, 0x1)
    mask = one
    for i in 1:(2 ^ num_inputs - 1)
        mask <<= 1
        mask |= one
    end
    return mask
end















## Uses the output of a chromosome to compute its fitness relative to the given goal  g.
## chrom_out is a 1-dimensional array containing the outputs of execute_chromosome
## The function fit_funct transforms the Hamming distance between chrom_out and g into a fitness
#function fitness(g::Goal, chrom_out::Array, fit_funct=fit_funct_default::Function)
#   sum = 0
#   for i in 1:g.num_outputs
#      sum += count_ones( chrom_out[i] $ g.truth_table[i] )
#   end
#   return fit_funct(sum)
#end
#
## The default function for transforming Hamming distance x into a fitness to be maximized.
## An alternative is to use the Hamming distance as a fitness to be minimized.
##   Then this function would be replace by the identity function.
#function fit_funct_default(x)
#   return 1.0/(1.0+x)
#end
#


# prints a packed goal in octal format
function print_goal_octal(g::GoalPacked)
    if g.interleaved
        @printf("(%d, %d, 0o%o interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
    else
        @printf("(%d, %d, 0o%o non-interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
    end
end

# prints a packed goal in hex format
function print_goal_hex(g::GoalPacked)
    if g.interleaved
        @printf("(%d, %d, %#X interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
    else
        @printf("(%d, %d, %#X non-interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
    end
end

# Composes two goals G and F which must be in packed interleaved format.
# The number of inputs of G must be equal to the number of outputs of F
function g_compose_f(G::GoalPacked, F::GoalPacked)  # compute  G o F, i. e., G composed with F
    if F.interleaved == false || G.interleaved == false
        error("Error in function g_compose_f.  Arguments must be interleaved goals.")
        end
        if F.num_outputs != G.num_inputs
        error("error in g_compose_f. f.num_outputs must equal g.num_inputs")
    end
    local zeros= convert(BitString,0x0)   # BitString of all zeros
    local ones = ~zeros                   #BitString of all ones
    local mask_f = (ones << F.num_outputs) $ ones
    local mask_g  = (ones << G.num_outputs) $ ones
    local r = convert(BitString,0)  # Used to construct the truth table of the result
    f = F.truth_table
    g = G.truth_table
    #@printf("mask f: o%o\n",mask_f)
    #@printf("mask g: o%o\n",mask_g)
    for k in 0:2^G.num_outputs-1
        f_k = f & mask_f    # f(k)
        #@printf("k:%d  f(k):    o%o  %#X\n",k,f_k,f_k)
        g_f_k = (g >> (G.num_outputs * f_k)) & mask_g
        #@printf("k:%d  g(f(k)): o%o  %#X\n",k,g_f_k,g_f_k)
        r = r $ g_f_k << (k * G.num_outputs)
        #@printf("g(f(k))<<(k* G.num_outputs): o%o  %#X\n",g_f_k << (k * G.num_outputs),g_f_k << (k * G.num_outputs))
        f = f >> F.num_outputs
    end
    result = GoalPacked(F.num_inputs,G.num_outputs,r,true)
    return result
end

# Reads the ".plu" file whose name is fname.
# "*.plu" files define goals in Julian Miller's version 1.1 of GGP.
# This version is limited to goals with at most 4 inputs and at most 4 outputs.
function read_plu(fname)
    num_inputs = 0
    num_outputs = 0
    outputs = BitString[]
    f = open(fname,"r")
    println("reading file: ",fname)
    for line in eachline(f)
        fields = split(line,' ')
        if fields[1][1] == '.'
            if fields[1][2] == 'i'
                num_inputs = int(fields[2])
                if num_inputs > 4
                    error("the number of inputs in this version of read_plu is limited to 4")
                end
            elseif fields[1][2] == 'o'
                num_outputs = int(fields[2])
                if num_outputs > 4
                    error("the number of outputs in this version of read_plu is limited to 4")
                end
            end
        else
            input_flag = true
            for f in fields
                if length(f) == 0
                    input_flag = false
                    #println()
                elseif f != "\r\n"
                    #@printf(" %#X",int(f))
                    if !input_flag
                        push!(outputs,convert(BitString,int(f)))
                    end
                end
            end
            #println()
        end
    end
    word_size = 2^num_inputs
    truth_table = convert(BitString,0)
    #print("outputs: ")
    for o in outputs
        #@printf(" %#X",o)
        truth_table = truth_table << word_size
        truth_table = truth_table $ o
    end
    #println()
    #@printf("goal: %#X\n",truth_table)
    goal = construct_goal(num_inputs,num_outputs,truth_table,true)
    return goal
end


