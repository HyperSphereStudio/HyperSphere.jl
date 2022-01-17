#Written By Johnathan Bizzano
module Functions
    using Reexport
    using ..Utils
    using ..Data
    using ..HyperDimensional
    
    export AbstractTrainable, train, train!, AbstractTrainer

    export ConstantPool

    const ConstantPool{T} = Array{T, 1}

    include("AbstractMathFun.jl")
    include("CommonStaticFunctions.jl")
    
    abstract type AbstractTrainable{T, N} <: AbstractMathFun{T, N} end
    abstract type AbstractTrainer{T, N} <: AbstractMathFun{T, N} end

    include("Error.jl")
    include("Optimization/Optimizer.jl")

    trainer(f::AbstractMathFun; precision=10) = ()
    train!(f::AbstractTrainer, data::AbstractDataSet) = ()
    train!(f::AbstractTrainer, data::AbstractDataSet; epochs::Int = 1, IsVerbose=true, testset::AbstractDataSet=data) = ()

    include("Impl/BuiltInFunctions.jl")
    @reexport using .BuiltInFunctions

    include("Regression/Regression.jl")
    @reexport using .Regression

end
