using CGP
using Base.Test

# Create some goals, these should all be equivalent to one another.

g_u = Goal(2, (0b0010, 0b0001))
g_p = BasicPackedGoal(2, 2, 0b00010010)
g_i = InterleavedPackedGoal(2, 2, 0b00000110)

@test convert(BasicPackedGoal, g_u) == g_p
@test convert(InterleavedPackedGoal, g_u) == g_i

@test convert(Goal, g_p) == g_u
@test convert(InterleavedPackedGoal, g_p) == g_i

@test convert(Goal, g_i) == g_u
@test convert(BasicPackedGoal, g_i) == g_p

@test Goal(2, (0b0000, 0b0000)) != g_u
@test BasicPackedGoal(2, 2, 0b00000000) != g_p
@test InterleavedPackedGoal(2, 2, 0b00000000) != g_i
