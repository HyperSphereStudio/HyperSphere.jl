module NeuralNet
    import Main.HyperSphere.Functions

    abstract type AbstractNeuralNet{Data_Type} <: Functions.AbstractMathmaticalFunction{Data_Type} end
    export AbstractNeuralNet

    include("Layer.jl")
    include("Gen3Net.jl")
end
