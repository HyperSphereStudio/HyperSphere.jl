#Written By Johnathan Bizzano
module NeuralNet
        
        using ..Utils
        using ..Data
        using ..Functions


        include("Processor.jl")
        include("Initializer.jl")
        include("ActivationFun.jl")
        include("Layer/Layer.jl")
        include("Model.jl")
end




