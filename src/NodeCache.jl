export  NodeCache, InputNodeCache, InteriorNodeCache, OutputNodeCache

# Stores whether the corresponding Node is active, i. e. is used during evaluation.
# If the corresponding Node is active, then the cache stores the its value.
# Values of active and cache are set when the corresponding Chromosome is executed.
abstract NodeCache

type InputNodeCache <: NodeCache
    active::Bool
end

InputNodeCache() = InputNodeCache(false)

type InteriorNodeCache <: NodeCache
    active::Bool
    cache::BitString
end

InteriorNodeCache() = InteriorNodeCache(false, convert(BitString, 0))

type OutputNodeCache <: NodeCache
    active::Bool
    cache::BitString
end

OutputNodeCache() = OutputNodeCache(false, convert(BitString, 0))

