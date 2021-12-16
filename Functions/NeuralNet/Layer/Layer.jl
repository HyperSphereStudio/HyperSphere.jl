export Layer

struct Layer
    constant_count::T
    layer_function::Function

    function Layer(constant_count::T, layer_function::Function) where T
        new{T}(constant_count, merge_function, layer_function)
    end

    function (l::Layer{T})(constant_pointer::APtr{T}, args::Array{T, 1}, output_array::Array{T, 1})::Bool where T where T2
        return l.layer_function(constant_pointer, args, output_array)
    end
end

include("MergeFunction.jl")
include("ConvolutionalLayer.jl")
include("NodeSetLayer.jl")
include("UniformNodeSetLayer.jl")
