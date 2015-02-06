using CGP
using Base.Test

# ZERO

@test ZERO.func() == 0

# ONE

@test ONE.func() == convert(BitString, 2 ^ 64 - 1)

# AND

@test apply(AND.func, [ZERO.func(), ZERO.func()]) == ZERO.func()
@test apply(AND.func, [ONE.func(), ZERO.func()]) == ZERO.func()
@test apply(AND.func, [ZERO.func(), ONE.func()]) == ZERO.func()
@test apply(AND.func, [ONE.func(), ONE.func()]) == ONE.func()
# Condensed hexadecimal format version
@test apply(AND.func, [0xC,0xA]) == 0x8

# OR

@test apply(OR.func, [ZERO.func(), ZERO.func()]) == ZERO.func()
@test apply(OR.func, [ONE.func(), ZERO.func()]) == ONE.func()
@test apply(OR.func, [ZERO.func(), ONE.func()]) == ONE.func()
@test apply(OR.func, [ONE.func(), ONE.func()]) == ONE.func()
# Condensed hexadecimal format version
@test apply(OR.func, [0xC,0xA]) == 0xE

# XOR

@test apply(XOR.func, [ZERO.func(), ZERO.func()]) == ZERO.func()
@test apply(XOR.func, [ONE.func(), ZERO.func()]) == ONE.func()
@test apply(XOR.func, [ZERO.func(), ONE.func()]) == ONE.func()
@test apply(XOR.func, [ONE.func(), ONE.func()]) == ZERO.func()
# Condensed hexadecimal format version
@test apply(XOR.func, [0xC,0xA]) == 0x6

# NOT

@test apply(NOT.func, [ZERO.func()]) == ONE.func()
@test apply(NOT.func, [ONE.func()]) == ZERO.func()
