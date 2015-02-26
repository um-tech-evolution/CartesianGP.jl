# A Goal is a Boolean function (perhaps multi-output) that defines result computed by a digital circuit
#    for all possible inputs.  This bit string of results is called the truth table.
export Goal, GoalPacked, construct_goal, print_goal, g_compose_f, interleave, de_interleave, read_plu

# Functions relating to Boolean function goals.
# Author:  Alden Wright, December 2014 to February 2015
#
# Goals can have multiple outputs.
# There are three formats for goals:
# unpacked:  each output is stored in a separate BitString (this is the output format of execute chromosome)
# packed (also called non-interleved):  All outputs are stored in one BitString.  
#      All bits of an output are consecutive.
# interleaved:  All outputs are stored in one BitString.
#      The bits of outputs are interleaved.  This format is used by the g_compose f function.

# GoalPacke is a goal type where all outputs are "packed" into one BitString.
# May be non-interleaved or interleaved.  
# The interleaved field should be true if interleaved, false if non-interleaved.
immutable GoalPacked
	num_inputs::Integer
	num_outputs::Integer
	truth_table::BitString
   interleaved::Bool
end

# An unpacked format goal.  In other words, each output is in a separate bit string
immutable Goal
	num_inputs::Integer
	num_outputs::Integer
	truth_table::Array
end

# Note that == will not work on separately defined Goals. (I don't understand why.)
# So I have defined the following isequal function on Goals
function isequal(g::Goal,h::Goal)
   return (g.num_inputs==h.num_inputs) && (g.num_inputs==h.num_inputs) && (g.truth_table==g.truth_table)
end

## Uses the output of a chromosome to compute its fitness relative to the given goal  g.
## chrom_out is a 1-dimensional array containing the outputs of execute_chromosome
## The function fit_funct transforms the Hamming distance between chrom_out and g into a fitness
#function fitness(g::Goal, chrom_out::Array, fit_funct=fit_funct_default::Function)
#   sum = 0
#   for i in 1:g.num_outputs
#      sum += count_ones( chrom_out[i] $ g.truth_table[i] )
#   end
#   return fit_funct(sum)
#end
#
## The default function for transforming Hamming distance x into a fitness to be maximized.
## An alternative is to use the Hamming distance as a fitness to be minimized.  
##   Then this function would be replace by the identity function.
#function fit_funct_default(x)
#   return 1.0/(1.0+x)
#end
#
# Unpacks a goal from non-interleaved format to unpacked format
function unpack_goal(g::GoalPacked) 
   if g.interleaved 
      error("Error in unpack_goal.  An interleaved goal cannot be unpacked.")
   end
   tmp_truth_table = g.truth_table
   result = Array(BitString,g.num_outputs)   # used to build the unpacked truth table
   mask = output_mask(g.num_inputs) 
   for i in 1:g.num_outputs
      result[i] = mask & tmp_truth_table
      tmp_truth_table >>= (2^g.num_inputs)
      #@printf("i:%d  %#X  %#X\n",i,tmp_truth_table,result[i])
   end
   return Goal(g.num_inputs,g.num_outputs,result)
end

# Packs a goal from unpacked format to packed (non-interleaved) format
function pack_goal(g::Goal) 
	result = convert(BitString,g.truth_table[g.num_outputs])  # used to build the truth table of the result
   mask = output_mask(g.num_inputs) 
   for i in g.num_outputs-1:-1:1
      result <<= (2^g.num_inputs)
      result $= g.truth_table[i]
   end
   return GoalPacked(g.num_inputs,g.num_outputs,result,false)
end

# converts interleaved GoalPacked to non-interleaved GoalPacked
function de_interleave(g::GoalPacked)
   if !g.interleaved 
      error("Error in function de_interleave.  Cannot de_interleave an non-interleaved goal.")
   end
   result = convert(BitString,0)   # used to build the truth table
	local one = convert(BitString,1)
	local in=g.truth_table
	local p = 2^g.num_inputs
	for k in g.num_outputs-1:-1:0
		for j in p-1:-1:0
			r = in >> (j*g.num_outputs+k)
			#@printf("j:%d   k:%d  j*g.num_outputs+k:%d  r&1:%d\n",j,k,j*g.num_outputs+k,r&one)
			result = (result << 1) $ (r & one)
		end
	end
	return GoalPacked(g.num_inputs,g.num_outputs,result,false)
end

# converts non-interleaved GoalPacked to interleaved GoalPacked
function interleave(g::GoalPacked)
   if g.interleaved 
      error("Error in function interleave.  Cannot interleave an interleaved goal.")
   end
	local result = convert(BitString,0)  # used to build the truth table
	local one = convert(BitString,1)
	local in=g.truth_table
	local p = 2^g.num_inputs
	for j in p-1:-1:0
		for k in g.num_outputs-1:-1:0
			r = in >> (k*(p-1)+j+k)
			#@printf("j:%d   k:%d  k*(p-1)+j+k:%d r:%#X  r&1:%d\n",j,k,k*(p-1)+j+k,r,r&one)
			result = (result << 1) $ (r & one)
		end
	end
	return GoalPacked(g.num_inputs,g.num_outputs,result,true)
end
	
# prints a packed goal in octal format
function print_goal_octal(g::GoalPacked)
   if g.interleaved
	   @printf("(%d, %d, 0o%o interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
   else
	   @printf("(%d, %d, 0o%o non-interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
   end
end
	
# prints a packed goal in hex format
function print_goal_hex(g::GoalPacked)
   if g.interleaved
	   @printf("(%d, %d, %#X interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
   else
	   @printf("(%d, %d, %#X non-interleaved)\n",g.num_inputs,g.num_outputs,g.truth_table)
   end
end

# prints an unpacked goal in hex format
# The truth table entries are printed starting from the highest index to the lowest index
# In other words, print_goal(Goal(2,2,[0x6,0x8]) will print "(2, 2, [0x8 0x6])"
# This will be explained in the documentation for bit strings.
function print_goal(g::Goal)
   @printf("(%d, %d, [",g.num_inputs,g.num_outputs)
   for i in g.num_outputs:-1:2
      @printf("%#x ",g.truth_table[i])
   end
   @printf("%#x",g.truth_table[1])
   println("])")
end

# Composes two goals G and F which must be in packed interleaved format.
# The number of inputs of G must be equal to the number of outputs of F
function g_compose_f(G::GoalPacked, F::GoalPacked)  # compute  G o F, i. e., G composed with F
   if F.interleaved == false || G.interleaved == false
      error("Error in function g_compose_f.  Arguments must be interleaved goals.")
   end
	if F.num_outputs != G.num_inputs
	   error("error in g_compose_f. f.num_outputs must equal g.num_inputs")
	end
	local zeros= convert(BitString,0x0)   # BitString of all zeros
	local ones = ~zeros                   #BitString of all ones
	local mask_f = (ones << F.num_outputs) $ ones
	local mask_g  = (ones << G.num_outputs) $ ones
	local r = convert(BitString,0)  # Used to construct the truth table of the result
	f = F.truth_table
	g = G.truth_table
	#@printf("mask f: o%o\n",mask_f)
	#@printf("mask g: o%o\n",mask_g)
	for k in 0:2^G.num_outputs-1
		f_k = f & mask_f    # f(k)
		#@printf("k:%d  f(k):    o%o  %#X\n",k,f_k,f_k)
		g_f_k = (g >> (G.num_outputs * f_k)) & mask_g
		#@printf("k:%d  g(f(k)): o%o  %#X\n",k,g_f_k,g_f_k)
		r = r $ g_f_k << (k * G.num_outputs)
		#@printf("g(f(k))<<(k* G.num_outputs): o%o  %#X\n",g_f_k << (k * G.num_outputs),g_f_k << (k * G.num_outputs))
		f = f >> F.num_outputs
	end
	result = GoalPacked(F.num_inputs,G.num_outputs,r,true)
	return result
end

# Reads the ".plu" file whose name is fname.
# "*.plu" files define goals in Julian Miller's version 1.1 of GGP.
# This version is limited to goals with at most 4 inputs and at most 4 outputs.
function read_plu(fname)
	num_inputs = 0
	num_outputs = 0
	outputs = BitString[]
	f = open(fname,"r") 
	println("reading file: ",fname)
	for line in eachline(f)
		fields = split(line,' ')
		if fields[1][1] == '.'
			if fields[1][2] == 'i'
				num_inputs = int(fields[2])
				if num_inputs > 4
					error("the number of inputs in this version of read_plu is limited to 4")
				end
			elseif fields[1][2] == 'o'
				num_outputs = int(fields[2])
				if num_outputs > 4
					error("the number of outputs in this version of read_plu is limited to 4")
				end
			end
		else
			input_flag = true
			for f in fields
				if length(f) == 0
					input_flag = false
					#println()
				elseif f != "\r\n"
					#@printf(" %#X",int(f))
					if !input_flag
						push!(outputs,convert(BitString,int(f)))
					end
				end
			end
			#println()
		end
	end
	word_size = 2^num_inputs
	truth_table = convert(BitString,0)
	#print("outputs: ")
	for o in outputs
		#@printf(" %#X",o)
		truth_table = truth_table << word_size
		truth_table = truth_table $ o
	end
	#println()
	#@printf("goal: %#X\n",truth_table)
	goal = construct_goal(num_inputs,num_outputs,truth_table,true)
	return goal
end


# Utility function which returns bitstring mask for one output of the packed representation
function output_mask(num_inputs)
   one = convert(BitString,0x1)
   mask = one
   for i in 1:(2^num_inputs-1)
      mask <<= 1
      mask |= one
   end
   return mask
end


