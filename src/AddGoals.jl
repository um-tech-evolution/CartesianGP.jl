using CGP

function add_input_to_goal(G::Goal,output,input)
   ab = input
   ni = G.num_inputs
   nb = 2^(ab-1)
   #println("ab:",ab,"  ni:",ni,"  nb:",nb)
   tt = G.truth_table[output]
   #@printf("tt:0X%X\n",tt)
   r = convert(BitString,0)
   for i in 1:2^(ni-ab+1)
      r <<= 2^ab
      m = output_mask(ab-1)
      s = (2^ni-2^(ab-1)*i)
      #@printf("i:%d  s:%d  r:0X%X  m:0X%X\n",i,s,r,m)
      m <<= s
      w = m & tt
      #@printf("m:0X%X  w:0X%X\n",m,w)
      w >>= s 
      w $= (w << nb)
      r $= w
      #@printf("w:0X%X  r:0X%X\n",w,r)
   end
   return Goal(G.num_inputs+1,(r,)) 
end 

# add (combine) two single-output goals G into a two-output goal
# The two input goals are overlapped as little as possbile.
function add(G::Goal, H::Goal, output_goal_num_inputs)
   if length(G.truth_table) > 1 || length(H.truth_table) > 1
      error("you can only add single-output goals")
   end
   G_num_bits = 2^G.num_inputs
   println("G_num_bits:",G_num_bits)
   H_num_bits = 2^H.num_inputs
   println("H_num_bits:",H_num_bits)
   if G.num_inputs > output_goal_num_inputs || H.num_inputs > output_goal_num_inputs
      error("output goal must have at least as many inputs as G and as H.")
   end
   diff_num_inputs = output_goal_num_inputs-G.num_inputs
   println("diff_num_inputs:",diff_num_inputs)
   one_bit = convert(BitString,0x1)
   ones = one_bit
   for j = 1:2^diff_num_inputs-1
      ones = (ones<<1)$ones
   end
   @printf("ones: 0X%X\n",ones)
   m = one_bit << (G_num_bits-1)
   @printf("m: 0X%X\n",m)
   result = convert(BitString,0x0)
   for i in G_num_bits:-1:1
      result <<= 2^diff_num_inputs
      if m & G.truth_table[1] != 0
         result = result $ ones
      end
      @printf("i:%d  result:0X%X\n",i,result)
      m >>= 1
   end
   return result
end

# Returns an array of BitStrings which are the inputs to a chromosome when it is executed to determine the
#    truth table of the chromosome.
# num_inputs  is the number of inputs of the chromosome
function std_input_context(num_inputs)
   if 2^num_inputs > 8*sizeof(BitString)
      error("number of inputs is too large for size of BitString in std_input_context")
   end
   std_in = Array(BitString,num_inputs)
   std_in[1] = 0b10
   for i in 2:num_inputs
      std_in[i] = output_mask(i-1) << 2^(i-1)
      for j in 1:(i-1)
         std_in[j] $= std_in[j] << 2^(i-1)
      end
   end
   return std_in
end

# Returns true if output "output_number" of goal "G" depends on "input".
function goal_depends_on(G::Goal,output_number,input)
   if output_number < 1
      error("output_number in goal_depends_on must be positive.")
   end
   if output_number > length(G.truth_table)
      error("output_number in goal_depends_on cannot be greater than the number of outputs of the goal.")
   end
   if input < 1
      error("input in goal_depends_on must be positive.")
   end
   if input > G.num_inputs
      error("input in goal_depends_on cannot be greater than the number of inputs of the goal.")
   end
   context = std_input_context(G.num_inputs)[input]
   tt= G.truth_table[output_number]
   #@printf("tt: 0X%X\n",tt)
   #@printf("context: 0X%X\n",context)
   shift = 2^(input-1)
   #println("shift:",shift)
   #shifted_context = input_context >> shift
   #@printf("shifted_context: 0X%X\n",(context >> shift))
   shifted_truth_table = tt >> shift
   #@printf("shifted_truth_table: 0X%X\n",shifted_truth_table)
   return (context >> shift) & tt != (context & tt) >> shift
end

# Test goal.  
GT = Goal(3,(0b10101100,0b01111001))
