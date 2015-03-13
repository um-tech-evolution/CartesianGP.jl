using CGP
using Base.Test

# Half adder

c = chromosome_half_adder()
g0 = goal_half_adder()
g1 = Goal(2, (0b0110, 0b1001))

@test_approx_eq fitness(c, g0) 1.0
@test_approx_eq fitness(c, g1) (1.0 / 2.0)
