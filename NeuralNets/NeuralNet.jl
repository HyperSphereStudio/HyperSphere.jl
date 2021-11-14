module NeuralNet
    import Main.HyperSphere.Functions

    abstract type AbstractNeuralNet{T} <: Functions.AbstractMathmaticalFunction{T} end
    export AbstractNeuralNet

    #include("FixedLengthNeuralNet.jl")
    #export FixedLengthNeuralNet, train, inactivate_training

    include("LinearFixedLengthNeuralNet.jl")

    #include("AbitraryLengthNeuralNet.jl")
end
