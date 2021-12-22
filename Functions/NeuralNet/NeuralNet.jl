export NeuralNetDesigner, NeuralNet, push_layer!

mutable struct NeuralNetDesigner{T, InputDim <: Integer, OutputDim <: Integer}
    layers::Vector{InternalLayer{T}}
    init_constant_vector::Vector{T}
    error_function::ErrorFunction{T}
    optimizer::Optimizer{T}
    constant_bounds::Vector{Bound{T}}

    function NeuralNetDesigner{T, I, O}(error_function=NeuralNet.meanabserr, optimizer=nothing) where T where I where O
            new{T, I, O}(Vector{Layer}(undef, 0), zeros(T, 0), error_function, optimizer)
    end

    function (d::NeuralNetDesigner{T})()::TrainableNeuralNet{T, InputDim, OutputDim} where T
            TrainableNeuralNet{T}(d)
    end

end

function push_layer!(designer::NeuralNetDesigner{T, I, O}, layer::Layer{T}) where T where I where O
        push!(designer.layers, InternalLayer{T}(layer.layer_function))
        append!(designer.init_constant_vector, layer.init_constant_vector)
end

struct NeuralNet{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractMathmaticalFunction{T}
    layers::Array{InternalLayer{T}}
    constants::ConstantPool{T}
    constant_bounds::Array{Bound{T}}
    error_function::ErrorFunction{T}

    function NeuralNet{T, I, O}(designer::NeuralNetDesigner{T}) where T where I where O
        new{T, I, O}(designer.input_length, designer.output_length, designer.layers,
                designer.init_constant_vector, designer.constant_bounds, designer.error_function)
    end

    function (f::NeuralNet{T, I, O})(args::Input{T, I}; DataType::Type=Float64)::Output{DataType, O} where T where I where O
            const_ptr = APtr(f.constants)
            for l in f.layers
                    args = l(const_ptr, args, DataType)
            end
            args
    end
end

function train!(f::NeuralNet{T, I, O}, data::AbstractDataSet; optimizer::Optimizer{T}=blackboxoptimizer, DataType::Type=Float64) where T where I where O
        optimizer(f.constants, 
                function (args)
                        newcons = args[1]
                        for i in 1:length(newcons)
                                constants[i] = newcons[i]
                        end
                        error_function(data, DataType)
                end, f.constant_bounds)
end