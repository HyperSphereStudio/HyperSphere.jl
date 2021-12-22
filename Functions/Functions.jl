module Functions
    import Main.HyperSphere
    using Main.HyperSphere.Utils
    using Main.HyperSphere.Data
    using Main.HyperSphere.HyperDimensional

    export AbstractTrainable, train, train!, set_trainable

    export Input, ConstantPool, Output

    const ConstantPool{T} = Array{T, 1}
    const Input{T, Len} = NTuple{Len, T}
    const Output{T, Len} = NTuple{Len, T}

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
