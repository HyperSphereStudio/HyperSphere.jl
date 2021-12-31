"Written By Johnathan Bizzano"
module Utils

    export Bound, Entry

    struct Bound{T <: Number}
        lower_bound::T
        upper_bound::T
        Bound{T}(lower_bound, upper_bound) where T = new{T}(T(lower_bound), T(upper_bound))
        Bound(lower_bound::T, upper_bound::T) where T = new{T}(lower_bound, upper_bound)
    end

    struct Entry{K, V}
        key::K
        value::V
        Entry{K, V}(key, value) where {K, V} = new{K, V}(K(key), V(value))
        Entry(key::K, value::V) where {K, V} = new{K, V}(K(key), V(value))
    end
    

    include("Fun.jl")
    include("APtr.jl")
    include("JuliaUtils.jl")
    include("Iterable.jl")
end