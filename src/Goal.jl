import Base.==
import Base.convert

export Goal, PackedGoal, BasicPackedGoal, InterleavedPackedGoal, print_goal, compose, convert, ==, read_plu

# A goal describes a boolean function with one or more inputs and one or more
# outputs. It defines the number of inputs and the values of each output for
# all possible input combinations.
immutable Goal{N}
    num_inputs::Integer
    truth_table::NTuple{N, BitString}
end

Goal{N}(n::Integer, t::NTuple{N, Integer}) = Goal(n, convert(NTuple{N, BitString}, t))
Goal(n::Integer, b::Vector{BitString}) = Goal(n, ntuple(i -> b[i], length(b)))
Goal(c::Chromosome, b::Vector{BitString}) = Goal(c.num_inputs, b)

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
=={T <: PackedGoal}(g::Goal, h::T) = error("Cannot compare unpacked and packed goals")
=={T <: PackedGoal}(g::T, h::Goal) = h == g

# Prints a packed goal in hex by converting it to an unpacked goal.
function print_goal{T <: PackedGoal}(g::T)
    print_goal(convert(Goal, g))
end

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
    if (2 ^ g.num_inputs) * N > 8*sizeof(BitString)  # 8 is the number of bits in a byte
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
        for k = (g.num_outputs-1):-1:0
            r = g.truth_table >> (k * (p - 1) + j + k)
            ttable = (ttable << 1) $ (r & one)
        end
    end
    return InterleavedPackedGoal(g.num_inputs, g.num_outputs, ttable)
end

function convert(::Type{BasicPackedGoal}, g::InterleavedPackedGoal)
    ttable = convert(BitString, 0)
    one = convert(BitString, 1)
    t_g = g.truth_table
    p = 2 ^ g.num_inputs
    for j = (g.num_outputs-1):-1:0
        for k = p-1:-1:0
            r = t_g >> (k * g.num_outputs + j)
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

# Compose two goals g, and h. The number of outputs from h must be
# equal to the number of inputs to g.
function compose(g::InterleavedPackedGoal, h::InterleavedPackedGoal)
    if g.num_inputs != h.num_outputs
        error("Cannot compose g and h, input-output mismatch.")
    end
    
    ones = typemax(BitString)

    mask_g = (ones << g.num_outputs) $ ones
    mask_h = (ones << h.num_outputs) $ ones

    ttable = convert(BitString, 0)

    t_g = g.truth_table
    t_h = h.truth_table

    for i = 0:(2 ^ h.num_outputs - 1)
        g_i = t_g & mask_g
        h_g_i = (t_h >> (h.num_outputs * g_i)) & mask_h
        ttable = ttable $ h_g_i << (i * h.num_outputs)
        t_g = t_g >> g.num_outputs
    end
    return InterleavedPackedGoal(g.num_inputs, h.num_outputs, ttable)
end

# Reads the ".plu" file whose name is fname.
# "*.plu" files define goals in Julian Miller's version 1.1 of GGP.
# This version is limited to goals with at most 4 inputs and at most 4 outputs.
function read_plu(fname)
    num_inputs = 0
    num_outputs = 0
    outputs = BitString[]
    f = open(fname,"r")
    for line in eachline(f)
        fields = split(line,' ')
        if fields[1][1] == '.'
            if fields[1][2] == 'i'
                num_inputs = parse(Int, fields[2])
                if num_inputs > 4
                    error("the number of inputs in this version of read_plu is limited to 4")
                end
            elseif fields[1][2] == 'o'
                num_outputs = parse(Int, fields[2])
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
                        push!(outputs,convert(BitString, parse(Int, f)))
                    end
                end
            end
            #println()
        end
    end
    word_size = 2^num_inputs
    truth_table = convert(BitString,0)
    for o in outputs
        #@printf(" %#X",o)
        truth_table = truth_table << word_size
        truth_table = truth_table $ o
    end
    return BasicPackedGoal(num_inputs, num_outputs, truth_table)
end


