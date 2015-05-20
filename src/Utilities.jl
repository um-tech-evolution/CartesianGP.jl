# Utility function which returns bitstring mask for one output of the
# packed representation.
# Examples:  output_mask(2) returns  0b1111 = 0XF
#        and output_mask(3) returns  0b11111111 = 0XFF
function output_mask(num_inputs)
    mask = convert(BitString, 0x1)
    for i in 0:(num_inputs-1)
        mask |= (mask << 2^i)
    end
    return mask
end

# Returns an array of BitStrings which are the standard inputs to a chromosome 
#    when it is executed. 
# num_inputs  is the number of inputs of the chromosome.
function std_input_context(num_inputs)
   if 2^num_inputs > 8*sizeof(BitString)
      error("number of inputs is too large for size of BitString in std_input_context")
   end
   std_in = Array(BitString,num_inputs)
   std_in[1] = 0b10
   for i in 2:num_inputs
      for j in i:-1:2
         std_in[j] = std_in[j-1] $ std_in[j-1] << 2^(i-1)
      end
      std_in[1] = output_mask(i-1) << 2^(i-1)
   end
   return std_in
end

