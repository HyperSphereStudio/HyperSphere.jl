module HyperSphere
    import Pkg
    using Reexport

    abstract type AbstractObject end

    export AbstractObject

    Base.show(buffer::IO, x::AbstractObject) = print(buffer, string(x))
    Base.show(io::IO, x::BitVector) = for i in 1:length(x); print(io, x[i] ? "1" : "0"); end

    include("Utilities/Utils.jl")
    @reexport using .Utils

    include("Math/Math.jl")
    @reexport using .HSMath

    include("HyperDimensional/HyperDimensional.jl")
    @reexport using .HyperDimensional

    include("Functions/Functions.jl")
    @reexport using .Functions

    include("NeuralNets/NeuralNet.jl")
    @reexport using .NeuralNet

    function install()
        Pkg.add("Reexport")
        Pkg.add("Combinatorics")
        Pkg.add("BlackBoxOptim")
    end

end
