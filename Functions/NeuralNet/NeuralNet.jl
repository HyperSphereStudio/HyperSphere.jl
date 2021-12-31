#Written By Johnathan Bizzano
module NeuralNet
        
        using ..Utils
        using ..Data
        using ..Functions


        include("Initializer.jl")
        include("ActivationFun.jl")
        include("Layer/Layer.jl")
        include("Model.jl")
end




