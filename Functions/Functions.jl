module Functions
    import Main.HyperSphere
    using Main.HyperSphere.Utils
    using Main.HyperSphere.Data
    using Main.HyperSphere.HyperDimensional

    export AbstractTrainable, train, inactivate_training, train!, ConstantPool

    const ConstantPool{T} = Array{T, 1}

    include("AbstractMathmaticalFunction.jl")
    abstract type AbstractTrainable{T} <: AbstractMathmaticalFunction{T} end

    train(f::AbstractTrainable, inputs::AbstractMatrix{T}, outputs::AbstractArray{T2}; Data_Type::Type=Float32) where T where T2 = train!(f, inputs, outputs, Data_Type = Data_Type)
    train!(f::AbstractTrainable, inputs::AbstractMatrix{T}, outputs::AbstractArray{T2}; Data_Type::Type=Float32) where T where T2 = 0

    inactivate_training(f::AbstractTrainable) = 0


    include("Regression/MultiVarPolynomial.jl")
    include("Error/Error.jl")
    include("Optimization/Optimizer.jl")
    include("NeuralNet/NeuralNetModule.jl")

end
