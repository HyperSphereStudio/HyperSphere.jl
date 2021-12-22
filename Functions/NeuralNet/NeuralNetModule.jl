module NeuralNetModule
        export Input

        const Input{T} = Array{T, 1}

        using Main.HyperSphere.Utils
        using Main.HyperSphere.Data
        using Main.HyperSphere.Functions

        include("Layer/Layer.jl")
        include("NeuralNet.jl")
end




