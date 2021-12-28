function hypersphere_install_pkgs(download_optional=false)
    Pkg.add("BlackBoxOptim")
    Pkg.add("StaticArrays")
    Pkg.add("Lazy")
    Pkg.add("Reexport")
    Pkg.add("Combinatorics")
    Pkg.add("BenchmarkTools")


    #Optional
    if download_optional
        Pkg.add("PyCall")
        Pkg.add("PyPlot")
        Pkg.add("QuadGK")
    end
end

module HyperSphere
    import Pkg
    using Reexport
    using Lazy

    const Double = Float64
    abstract type AbstractObject end
    
    export AbstractObject, Double

    Base.show(buffer::IO, x::AbstractObject) = print(buffer, string(x))
    Base.show(io::IO, x::BitVector) = for i in 1:length(x); print(io, x[i] ? "1" : "0"); end

    include("Utilities/Utils.jl")
    @reexport using .Utils

    include("Math/Math.jl")
    @reexport using .HSMath

    include("HyperDimensional/HyperDimensional.jl")
    @reexport using .HyperDimensional

    include("Data/Data.jl")
    @reexport using .Data

    include("Functions/Functions.jl")
    @reexport using .Functions

    include("Vector/Vector.jl")
    @reexport using .MVector
end
