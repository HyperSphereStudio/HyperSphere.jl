export NeuralNetDesigner, NeuralNet

import Main.HyperSphere.Functions
import Main.HyperSphere.Data
using BlackBoxOptim

include("Layer/Layer.jl")
include("TrainableNeuralNet.jl")

mutable struct NeuralNetDesigner{T, InputDim <: Integer, OutputDim <: Integer}
        layers::Vector{Layer}
        init_constant_vector::Vector{T}

        error_function::Function
        optimizer::Optimizer

        function NeuralNetDesigner{I, O}(error_function=NeuralNet.meanabserr, optimizer=nothing) where T where I where O
                new{T, input_length, output_length}(Vector{Layer}(undef, 0), zeros(T, 0), error_function, optimizer)
        end

        function (d::NeuralNetDesigner{T})()::TrainableNeuralNet{T, InputDim, OutputDim} where T
                TrainableNeuralNet{T}(d)
        end
end

struct NeuralNet{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractMathmaticalFunction{T}
        layers::Array{Layer, 1}
        constants::Array{T, 1}

        function NeuralNet{T}(designer::NeuralNetDesigner{T}) where T
                sum = 0
                for l in designer.layers
                        sum += l.constant_count
                end
                new{T}(designer.input_length, designer.output_length, layers,
                        designer.init_constant_vector)
        end

        function (f::NeuralNet{T, I, O})(args::Array{T, 1}) where T where I where O
                const_ptr = APtr(f.constants)
                output_vec = Data_Type[]
                for l in f.layers
                        args = l(const_ptr, output_vec, args)
                        const_ptr += l.constant_count
                end
        end
end
