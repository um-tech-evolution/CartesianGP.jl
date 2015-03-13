using CGP
using Base.Test

# Create some 2-input goals, these should all be equivalent to one another.

g2_u = Goal(2, (0b0010, 0b0001))
g2_p = BasicPackedGoal(2, 2, 0b00010010)
g2_i = InterleavedPackedGoal(2, 2, 0b00000110)

@test convert(BasicPackedGoal, g2_u) == g2_p
@test convert(InterleavedPackedGoal, g2_u) == g2_i

@test convert(Goal, g2_p) == g2_u
@test convert(InterleavedPackedGoal, g2_p) == g2_i

@test convert(Goal, g2_i) == g2_u
@test convert(BasicPackedGoal, g2_i) == g2_p

@test Goal(2, (0b0000, 0b0000)) != g2_u
@test BasicPackedGoal(2, 2, 0b00000000) != g2_p
@test InterleavedPackedGoal(2, 2, 0b00000000) != g2_i

@test_throws ErrorException g2_u == g2_p
@test_throws ErrorException g2_p == g2_u
@test_throws ErrorException g2_p == g2_i
@test_throws ErrorException g2_i == g2_p
@test_throws ErrorException g2_u == g2_i
@test_throws ErrorException g2_i == g2_u

# Create some 3-input 3-output goals: these should all be equivalent to one another.
g3_uh = Goal(3,(0xC9,0x0F,0xA5))  # hexadecimal version
g3_ub = Goal(3,(0b11001001,0b00001111,0b10100101)) # equivalent binary version
g3_ph = BasicPackedGoal(3,3,0xA50FC9)
g3_io = InterleavedPackedGoal(3,3,0o51403627) # octal is most natural for this goal

@test g3_ub == g3_uh  # check that binary and hex versions are the same
@test convert(BasicPackedGoal, g3_uh) == g3_ph
@test convert(Goal, g3_ph) == g3_uh
@test convert(InterleavedPackedGoal, g3_ph) == g3_io
@test convert(BasicPackedGoal, g3_io) == g3_ph
@test convert(Goal, g3_io) == g3_ub
@test convert(Goal, g3_ph) == g3_ub

# Create goals to test the composition of goals
g3_inv = InterleavedPackedGoal(3,3,0o02753164)  # compositional inverse of g3_io
g3_ident = InterleavedPackedGoal(3,3,0o76543210)# compositional identity function
@test compose(g3_io,g3_inv) == g3_ident
@test compose(g3_inv,g3_io) == g3_ident
@test compose(g3_io,g3_ident) == g3_io
@test compose(g3_ident,g3_inv) == g3_inv

fname = "add1c.plu"
add1c_goal = Goal(3,(0x96,0xE8))
print_goal(add1c_goal)
add1c_plu_goal = read_plu(fname)
print_goal(add1c_plu_goal)

@test read_plu(fname) == convert(BasicPackedGoal,add1c_goal)
#println("Goal read from file ",fname)
#print_goal(RG)

