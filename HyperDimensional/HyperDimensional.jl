module HyperDimensional
    struct DimensionException <: Exception
        args
        msg
        DimensionException(msg, args...) = new(msg, [string(arg) for arg in args])
        Base.showerror(io::IO, e::DimensionException) = print(io, msg * " [" * join(args, ", ") * "]")
    end

    export DimensionException

    include("../Utilities/Utils.jl")
    using .Utils

    include("Iteration.jl")
    include("Math.jl")

end
