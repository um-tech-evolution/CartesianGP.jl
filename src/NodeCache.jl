export  NodeCache, InputNodeCache, InteriorNodeCache, OutputNodeCache

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

