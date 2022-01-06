#Written By Johnathan Bizzano
module Initializer
    using ..Utils

    @Fun(Func{StorageType}, cons_and_bounds::StorageType, idx::Int)

    export RNG, None
    
    None() = MemoryWrapper(sett -> Func{sett.storageType}(idx -> 0))
    RNG() = MemoryWrapper(sett -> Func{sett.storageType}(idx -> rand(range)))
end



