module Initializer
    using ..Utils

    @Fun(Func{T}, cons_and_bounds::Tuple{T, Bound{T}}, idx::Int)

    export RNGInitializer
    
    RNGInitializer(T::Type, range)::Func{T} = Func{T}(idx -> (rand(range), Bound{T}(first(range), last(range))))
end



