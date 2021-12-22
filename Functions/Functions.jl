module Functions
    import Main.HyperSphere
    using Main.HyperSphere.Utils
    using Main.HyperSphere.Data
    using Main.HyperSphere.HyperDimensional

    export AbstractTrainable, train, train!, ConstantPool, set_trainable

    const ConstantPool{T} = Array{T, 1}

    include("AbstractMathmaticalFunction.jl")
    abstract type AbstractTrainable{T} <: AbstractMathmaticalFunction{T} end

    include("Error/Error.jl")
    include("Optimization/Optimizer.jl")

    train!(f::AbstractTrainable, data::AbstractDataSet, outputs::AbstractArray{T2}; Data_Type::Type=Float32) where T where T2 = ()
    train!(f::AbstractTrainable, data::AbstractDataSet; optimizer::Optimizer{T}=blackboxoptimizer) where T where I where O = ()
    set_trainable!(f::AbstractTrainable) = ()

    include("Regression/MultiVarPolynomial.jl")
    include("NeuralNet/NeuralNetModule.jl")

end
