export TrainableNeuralNet, train!

mutable struct TrainableNeuralNet{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractTrainable{T}
        data::DataSet{T, InputDim, OutputDim}
        neural_net::NeuralNet{T, InputDim, OutputDim}
        error_function::Function
        optimizer::Function

        function TrainableNeuralNet(neural_net::NeuralNet{T, InputDim, OutputDim};
                        data::DataSet{T, InputDim, OutputDim} = MatrixDataSet(T, InputDim, OutputDim), designer.error_function, designer.optimizer) where T where InputDim <: Integer where OutputDim <: Integer
                new{T, InputDim, OutputDim}(data, neural_net)
        end

        function (f::TrainableNeuralNet{T, I, O})(args::Array{T, 1}) where T where I where O
                f.neural_net(args)
        end
end

function train!(f::TrainableNeuralNet{T})  where T
        f.optimizer(f.constants,
                function (constants)
                        for i in 1:length(constants)
                                f.constants[i] = constants[i]
                        end
                        f.error_function()
                end)
end
