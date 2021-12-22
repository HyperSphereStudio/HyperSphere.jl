export Layer

using .Utils

struct Layer{T}
    constant_count::T
    layer_function::Function

    function Layer{T}(constant_count, layer_function::Function) where T
        new{T}(constant_count, layer_function)
    end

    function (l::Layer{T})(constant_pointer::APtr{T}, args::Input{T}, output_array::Array{T, 1})::Bool where T
        return l.layer_function(constant_pointer, args, output_array)
    end
end

include("MergeFunction.jl")
include("ConvolutionalLayer.jl")
include("NodeSetLayer.jl")
include("UniformNodeSetLayer.jl")
