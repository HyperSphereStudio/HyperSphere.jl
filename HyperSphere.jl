#Written By Johnathan Bizzano
function hypersphere_install_pkgs(download_optional=false)
    Pkg.add("Lazy")
    Pkg.add("Reexport")
    Pkg.add("Combinatorics")
    Pkg.add("BenchmarkTools")
    Pkg.add("MLDatasets")
    Pkg.add("CUDA")
    Pkg.add("LoopVectorization")
    Pkg.add("StaticArrays")

    #Optional
    if download_optional
        Pkg.add("PyCall")
        Pkg.add("PyPlot")
    end
end

module HyperSphere
    import Pkg
    using Reexport
    using Lazy
    using CUDA

    const Double = Float64
    abstract type AbstractObject end
    
    export AbstractObject, Double

    Base.show(buffer::IO, x::AbstractObject) = print(buffer, string(x))
    Base.show(io::IO, x::BitVector) = for i in 1:length(x); print(io, x[i] ? "1" : "0"); end

    include("Utilities/Utils.jl")
    @reexport using .Utils

    include("Computation/Device.jl")
    @reexport using .Devices

    include("Math/Math.jl")
    @reexport using .HSMath

    include("HyperDimensional/HyperDimensional.jl")
    @reexport using .HyperDimensional

    include("Data/Data.jl")
    @reexport using .Data

    include("Functions/Functions.jl")
    @reexport using .Functions

    include("NeuralNet/NeuralNet.jl")
    @reexport using .NeuralNet



    function __init__()
        __init_device__()
    end
end
