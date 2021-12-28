module Functions
    using Reexport
    using ..Utils
    using ..Data
    using ..HyperDimensional

    export AbstractTrainable, train, train!, AbstractTrainer

    export Input, ConstantPool, Output

    const ConstantPool{T} = Array{T, 1}
    const Input{T, Len} = NTuple{Len, T}
    const Output{T, Len} = NTuple{Len, T}

    include("AbstractMathFun.jl")
    include("CommonStaticFunctions.jl")
    
    abstract type AbstractTrainable{T, N} <: AbstractMathFun{T, N} end
    abstract type AbstractTrainer{T, N} <: AbstractMathFun{T, N} end

    include("Error.jl")
    include("Optimizer.jl")

    trainer(f::AbstractMathFun; precision=10) = ()
    trainer(f::AbstractMathFun, optimizer::Optimizer.Wrapper) = ()
    train!(f::AbstractTrainer, data::AbstractDataSet) = ()

    include("Impl/BuiltInFunctions.jl")
    @reexport using .BuiltInFunctions

    include("Regression/Regression.jl")
    @reexport using .Regression

    include("NeuralNet/NeuralNet.jl")
    @reexport using .NeuralNet
    

end
