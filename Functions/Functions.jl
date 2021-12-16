module Functions
    import Main.HyperSphere

    export AbstractTrainable, train, inactivate_training, train!

    include("AbstractMathmaticalFunction.jl")
    abstract type AbstractTrainable{T} <: AbstractMathmaticalFunction{T} end

    include("../Utilities/Utils.jl")
    using .Utils

    train(f::AbstractTrainable, inputs::AbstractMatrix{T}, outputs::AbstractArray{T2}; Data_Type::Type=Float32) where T where T2 = train!(f, inputs, outputs, Data_Type = Data_Type)
    train!(f::AbstractTrainable, inputs::AbstractMatrix{T}, outputs::AbstractArray{T2}; Data_Type::Type=Float32) where T where T2 = 0

    inactivate_training(f::AbstractTrainable) = 0


    include("../HyperDimensional/HyperDimensional.jl")
    using .HyperDimensional


    include("Regression/MultiVarPolynomial.jl")
    include("Error/Error.jl")
    include("Optimization/Optimizer.jl")
    include("NeuralNet/NeuralNet.jl")

end
