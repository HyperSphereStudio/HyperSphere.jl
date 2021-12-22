module Utils

    export Bound, Entry

    const Bound{T <: Number} = Tuple{T, T}
    lower_bound(x::Bound{T}) where T <: Number = x[1]
    upper_bound(x::Bound{T}) where T <: Number = x[2]

    const Entry{K, V} = Tuple{K, V}


    include("Fun.jl")
    include("APtr.jl")
    include("JuliaUtils.jl")
    include("Iterable.jl")
end