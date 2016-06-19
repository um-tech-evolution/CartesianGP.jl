export stdctx

typealias Context Vector{BitString}

@doc """Returns a bit mask for one packed input.

The logic here is fairly simple. If there are N inputs, then there are
2^N possible combinations of inputs and the corresponding values for
a single input require 2^N bits to represent. This function provides
a convenient mask that isolates the bits for a single input.

TODO: This can be optimized to return (2^(N+1)-1) for all but max N.

Example:

```
outmask(2) # 0b1111
outmask(3) # 0b11111111
```
"""
function outmask(inputct)
  mask = BitString(0b1)
  for i = 0:(inputct-1)
    mask |= mask << 2^i
  end
  return mask
end

@doc """Returns a standard input context for a given number of inputs.

The standard input context is an array of BitStrings, each corresponding to an
input. Together, they represent all possible input combinations. For a context
with N inputs, the Nth element of the array will change "fastest" (in other
words, it will alternate between 1 and 0).

Example:

```
c = stdctx(3)
bits(c[1]) # ...11110000
bits(c[2]) # ...11001100
bits(c[3]) # ...10101010
```

TODO: This would be a good candidate for caching.
"""
function stdctx(inputs)
  if 2^inputs > 8 * sizeof(BitString) # sizeof(...) returns bytes
    error("stdctx: Number of inputs is too large")
  end

  ctx = Array(BitString, inputs)
  ctx[1] = 0b10
  for i = 2:inputs
    for j = i:-1:2
      ctx[j] = ctx[j-1] $ ctx[j-1] << 2^(i-1)
    end
    ctx[1] = outmask(i - 1) << 2^(i-1)
  end
  return ctx
end
