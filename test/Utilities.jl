using CartesianGP
using Base.Test

reload("Utilities.jl")

@test output_mask(1) == convert(BitString,0b11)
@test output_mask(2) == convert(BitString,0b1111)
@test output_mask(3) == convert(BitString,0b11111111)
@test output_mask(4) == convert(BitString,0b1111111111111111)

@test std_input_context(1) == BitString[0b10]
@test std_input_context(2) == BitString[0b1100,0b1010]
@test std_input_context(3) == BitString[0b11110000,0b11001100,0b10101010]
@test std_input_context(4) == BitString[0b1111111100000000,0b1111000011110000,0b1100110011001100,0b1010101010101010]

