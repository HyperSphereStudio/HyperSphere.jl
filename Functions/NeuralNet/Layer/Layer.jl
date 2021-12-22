export Layer, LayerFunction, InternalLayer

using .Utils

const LayerFunction{T} = Fun{T, Tuple{APtr{T}, Array{T}, Type}}

mutable struct Layer{T}
    init_constants::Array{T}
    layer_function::LayerFunction{T}

    Layer{T}(init_constants::Array{T}, layer_function::Function) where T = new{T}(init_constants, layer_function)
end

struct InternalLayer{T}
    const_length::Int
    layer_function::LayerFunction{T}

    InternalLayer{T}(l::Layer{T}) where T = new{T}(length(l.init_constants), l.layer_function)

    function (l::InternalLayer{T})(constant_pointer::APtr{T}, inputs::Array{DataType}, DataType::Type)::DataType where T
        out = l.layer_function(constant_pointer, inputs, DataType)
        increment!(constant_pointer, l.const_length)
        return out
    end
end

include("MergeFunction.jl")
include("ConvolutionalLayer.jl")
include("NodeSetLayer.jl")
include("UniformNodeSetLayer.jl")
