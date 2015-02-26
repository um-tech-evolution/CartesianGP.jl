using CGP
using Base.Test
include("../src/Goal.jl")

# Tests of functions in src/Goal.jl
verbose = false

# Test interleave and de_interleave
# A 3-input 3-output goal packed interleaved goal
g3int = GoalPacked(3,3,0o51403627,true)
if verbose print("g3 interleaved: "); print_goal_octal(g3int) end
# The non-interleaved version of g3int
g3ni = GoalPacked(3,3,0xA50FC9,false)
if verbose print("g3 non-interleaved:  "); print_goal_hex(g3ni) end
@test de_interleave(g3int) == g3ni
@test interleave(g3ni) == g3int
@test interleave(de_interleave(g3int)) == g3int

# Test g_compose_f
# The inverse of g3int
g3inv = GoalPacked(3,3,0o02753164,true)
# The 3-input 3-output identity function in packed interleaved format
if verbose print("g3 inverse:  "); print_goal_octal(g3inv) end
ident3 = GoalPacked(3,3,0o76543210,true)
if verbose print("identity: "); print_goal_octal(ident3) end
if verbose print("g3 compose h3: ");print_goal_octal(g_compose_f(g3int,ident3)) end
@test g_compose_f(g3int,g3inv) == ident3
if verbose print("h3 compose g3: ");print_goal_octal(g_compose_f(ident3,g3int)) end
@test g_compose_f(g3inv,g3int) == ident3

# Test pack and unpack
# The unpacked version of g3ni
g3unp = Goal(3,3,[0xC9,0x0F,0xA5])  #Note: truth_table components are in the opposite order of what is shown in print_goal
if verbose print("g3 unpacked:    "); print_goal(g3unp) end
@test isequal(unpack_goal(g3ni), g3unp)  # Note that == doesn't work.  
@test pack_goal(g3unp)==g3ni
@test isequal(unpack_goal(pack_goal(g3unp)),g3unp)
@test pack_goal(unpack_goal(g3ni))==g3ni

# test fitness
#@test fitness(g3unp,g3unp.truth_table)==1.0
#g3pert = GoalPacked(3,3,0xA40FC9,false)   # differs in one bit from g3ni, should have fitness 0.5
#if verbose print("g3 perturbed by 1 bit: ");print_goal_hex(g3pert) end
#@test fitness(unpack_goal(g3pert),g3unp.truth_table)==0.5
