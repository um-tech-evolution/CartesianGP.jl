using CGP

# Adds an input to goal G.
# The new input is "ignored", i. e. changing the value of the new input has no affect on the output of the returned goal.
# The result is a goal with the same number of outputs as G, but one more input.
# If input_number is 1, the new input is the first input
# If input_number is G.num_inputs+1, the new input follows all of the inputs of G.
function add_input_to_goal(G::Goal,input_number)
    Goal(G.num_inputs+1,map(o->add_input_to_goal_output(G,o,input_number).truth_table[1],(1:length(G.truth_table))))
end

# This version adds a single "ignored" input to one output of the given goal.
# The new input is "ignored", i. e. changing the value of the new input has no affect on the output of the returned goal.
# It returns a 1-output goal
function add_input_to_goal_output(G::Goal,output_number,input_number)
    if output_number < 1
        error("output_number in add_input_to_goal_output must be positive.")
    end
    if output_number > length(G.truth_table)
        error("output_number in add_input_to_goal_output cannot be greater than the number of outputs of the goal.")
    end
    if input_number < 1
        error("input_number in add_input_to_goal_output must be positive.")
    end
    if input_number > G.num_inputs+1
        error("input_number in add_input_to_goal_output cannot be greater than G.num_inputs+1.")
    end
    ni = G.num_inputs
    nb = 2^(input_number-1)
    tt = G.truth_table[output_number]
    result = convert(BitString,0)
    for i in 1:2^(ni-input_number+1)
        result <<= 2^input_number
        m = output_mask(input_number-1)
        s = (2^ni-2^(input_number-1)*i)
        m <<= s
        w = m & tt
        w >>= s 
        w $= (w << nb)
        result $= w
    end
    return Goal(G.num_inputs+1,(result,)) 
end 

# Tests whether one of the inputs is "ignored".  
# Returns a vector of {true,false}.
# The ith component of this vector is true if the specified input affects output i and is false otherwise.
function goal_depends_on(G::Goal,input_number)
    map(o->goal_output_depends_on(G,o,input_number),[1:length(G.truth_table)])
end

# Returns true if modifying the input_number input changes the "ouput_number" output of G
# Returns false if modifying the input_number input does not change the output of G
function goal_output_depends_on(G::Goal,output_number,input_number)
    if output_number < 1
        error("output_number in goal_output_depends_on must be positive.")
    end
    if output_number > length(G.truth_table)
        error("output_number in goal_output_depends_on cannot be greater than the number of outputs of the goal.")
    end
    if input_number < 1
        error("input_number in goal_output_depends_on must be positive.")
    end
    if input_number > G.num_inputs
        error("input_number in goal_output_depends_on cannot be greater than G.num_inputs.")
    end
    context = std_input_context(G.num_inputs)[input_number]
    tt= G.truth_table[output_number]
    shift = 2^(input_number-1)
    return (context >> shift) & tt != (context & tt) >> shift
end

# combine two goals G and H into a two-output goal
# Ignored inputs are added to the end of the inputs of G to bring the number inputs up to output_goal_num_inputs
# Ignored inputs are added to the beginning of the inputs of H to bring the number inputs up to output_goal_num_inputs
# The two input goals are overlapped as little as possbile.
function combine_goals(G::Goal, H::Goal, output_goal_num_inputs)
    diffG = output_goal_num_inputs - G.num_inputs
    diffH = output_goal_num_inputs - H.num_inputs
    if diffG < 0 ||  diffH < 0
        error("the number of inputs of the returned Goal must be at least as large as the number of inputs of each of the combined goals.")
    end
    Gnew = G
    for i in [1:diffG]
        Gnew = add_input_to_goal(Gnew,Gnew.num_inputs+1)
    end
    Hnew = H
    for i in [1:diffH]
        Hnew = add_input_to_goal(Hnew,1)
    end
    Goal(output_goal_num_inputs,tuple(Gnew.truth_table..., Hnew.truth_table...))
end
