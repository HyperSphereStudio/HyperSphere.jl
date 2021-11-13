module Functions
    import Main.HyperSphere

    export AbstractTrainable, train, inactivate_training, train!

    include("../Utilities/Utils.jl")
    using .Utils

    abstract type AbstractTrainable <: HyperSphere.AbstractObject end

    train(f::AbstractTrainable, inputs::AbstractMatrix{T}, outputs::AbstractArray{T2}; Data_Type::Type=Float32) where T where T2 = train!(f, inputs, outputs, Data_Type = Data_Type)
    train!(f::AbstractTrainable, inputs::AbstractMatrix{T}, outputs::AbstractArray{T2}; Data_Type::Type=Float32) where T where T2 = 0

    inactivate_training(f::AbstractTrainable) = 0


    include("../HyperDimensional/HyperDimensional.jl")
    using .HyperDimensional

    include("AbstractMathmaticalFunction.jl")
    include("MultiVarPolynomial.jl")
end
