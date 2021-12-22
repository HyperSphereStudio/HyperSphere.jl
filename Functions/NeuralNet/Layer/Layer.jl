export Layer

using .Utils


const LayerFunction{T} = Fun{Bool, Tuple{APtr{T}, APtr{T}}}

struct Layer{T}
    init_constants::Array{T, 1}
    layer_function::LayerFunction{T}

    Layer{T}(init_constants::Array{T, 1}, layer_function::Function) where T = new{T}(init_constants, layer_function)

    function (l::Layer{T})(constant_pointer::APtr{T})::T where T
        
        return 
    end
end

include("MergeFunction.jl")
include("ConvolutionalLayer.jl")
include("NodeSetLayer.jl")
include("UniformNodeSetLayer.jl")
