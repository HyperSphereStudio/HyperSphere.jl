module NeuralNet
    import Main.HyperSphere.Functions

    abstract type AbstractNeuralNet <: Functions.AbstractTrainable end
    export AbstractNeuralNet

    #include("FixedLengthNeuralNet.jl")
    #export FixedLengthNeuralNet, train, inactivate_training

    include("LinearFixedLengthNeuralNet.jl")

    #include("AbitraryLengthNeuralNet.jl")
end
