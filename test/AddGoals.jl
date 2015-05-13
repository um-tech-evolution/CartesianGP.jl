using CGP
import CGP.output_mask
import CGP.std_input_context
using Base.Test

reload("../src/AddGoals.jl")


G1A = Goal(2, (0b1010, ))
G1B = Goal(3, (0b11001001,))
G3A = Goal(3,(0b10101010,0b01010101,0b11000011))
G3B = Goal(3, (0b11001001, 0b10101111, 0b10100101)) # equivalent binary version

@test add_input_to_goal(G1A,1) == Goal{1}(3,(0x00000000000000cc,))
@test add_input_to_goal(G1A,2) == Goal{1}(3,(0x00000000000000aa,))
@test add_input_to_goal(G1A,3) == Goal{1}(3,(0x00000000000000aa,))
@test_throws ErrorException add_input_to_goal(G1A,4)
@test goal_depends_on(G1A,1) == [true]
@test goal_depends_on(G1A,2) == [false]
@test_throws ErrorException goal_depends_on(G1A,3)
@test combine_goals(G1A,G1B,3) == Goal{2}(3,(0x00000000000000aa,0x00000000000000c9))
@test combine_goals(G1B,G1A,3) == Goal{2}(3,(0x00000000000000c9,0x00000000000000cc))
@test_throws ErrorException combine_goals(G1B,G1B,2)  # number of output goal inputs is too small
@test add_input_to_goal(G3B,1) == Goal{3}(4,(0x000000000000f0c3,0x000000000000ccff,0x000000000000cc33))
@test add_input_to_goal(G3B,4) == Goal{3}(4,(0x000000000000c9c9,0x000000000000afaf,0x000000000000a5a5))
@test goal_depends_on(G1B,1) == [true]
@test map(i->goal_depends_on(G1B,i),[1:G1B.num_inputs]) == Vector{Bool}[[true],[true],[true]]
@test map(i->goal_depends_on(G3B,i),[1:G3B.num_inputs]) == Vector{Bool}[[true,true,true],[true,false,false],[true,true,true]]
@test combine_goals(G3A,G3B,4) == Goal{6}(4,(0xaaaa,0x5555,0xc3c3,0xf0c3,0xccff,0xcc33))
