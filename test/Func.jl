using CGP
using Base.Test

# ZERO

@test ZERO.func() == 0

# ONE

@test ONE.func() == typemax(BitString)

# AND

@test apply(AND.func, [ZERO.func(), ZERO.func()]) == ZERO.func()
@test apply(AND.func, [ONE.func(), ZERO.func()]) == ZERO.func()
@test apply(AND.func, [ZERO.func(), ONE.func()]) == ZERO.func()
@test apply(AND.func, [ONE.func(), ONE.func()]) == ONE.func()

# OR

@test apply(OR.func, [ZERO.func(), ZERO.func()]) == ZERO.func()
@test apply(OR.func, [ONE.func(), ZERO.func()]) == ONE.func()
@test apply(OR.func, [ZERO.func(), ONE.func()]) == ONE.func()
@test apply(OR.func, [ONE.func(), ONE.func()]) == ONE.func()

# XOR

@test apply(XOR.func, [ZERO.func(), ZERO.func()]) == ZERO.func()
@test apply(XOR.func, [ONE.func(), ZERO.func()]) == ONE.func()
@test apply(XOR.func, [ZERO.func(), ONE.func()]) == ONE.func()
@test apply(XOR.func, [ONE.func(), ONE.func()]) == ZERO.func()

# NOT

@test apply(NOT.func, [ZERO.func()]) == ONE.func()
@test apply(NOT.func, [ONE.func()]) == ZERO.func()
