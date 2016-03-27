using CartesianGP
using Base.Test

# ZERO

@test ZERO.func() == 0

# ONE

@test ONE.func() == typemax(BitString)

# AND

@test AND.func([ZERO.func(), ZERO.func()]...) == ZERO.func()
@test AND.func([ONE.func(), ZERO.func()]...) == ZERO.func()
@test AND.func([ZERO.func(), ONE.func()]...) == ZERO.func()
@test AND.func([ONE.func(), ONE.func()]...) == ONE.func()

# OR

@test OR.func([ZERO.func(), ZERO.func()]...) == ZERO.func()
@test OR.func([ONE.func(), ZERO.func()]...) == ONE.func()
@test OR.func([ZERO.func(), ONE.func()]...) == ONE.func()
@test OR.func([ONE.func(), ONE.func()]...) == ONE.func()

# XOR

@test XOR.func([ZERO.func(), ZERO.func()]...) == ZERO.func()
@test XOR.func([ONE.func(), ZERO.func()]...) == ONE.func()
@test XOR.func([ZERO.func(), ONE.func()]...) == ONE.func()
@test XOR.func([ONE.func(), ONE.func()]...) == ZERO.func()

# NOT

@test NOT.func([ZERO.func()]...) == ONE.func()
@test NOT.func([ONE.func()]...) == ZERO.func()
