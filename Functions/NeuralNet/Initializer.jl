"Written By Johnathan Bizzano"
module Initializer
    using ..Utils

    @Fun(Func{StorageType}, cons_and_bounds::Tuple{StorageType, Bound{StorageType}}, idx::Int)
    @Fun(Wrapper, Func, StorageType::Type)

    export RNG, None
    
    None(range) = Wrapper(ST -> Func{ST}(idx -> 0))
    RNG(range;) = Wrapper(ST -> Func{ST}(idx -> (rand(range), Bound{ST}(first(range), last(range)))))
end



