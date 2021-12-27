module Layers
    using ..Utils
    import ..Initializer

    @VFun(Func{T}, constant_pointer::APtr{T}, inputs::Array{T, 1}, outputs::Array{T, 1})

    export Layer, InternalLayer

    mutable struct Layer{T, N, O}
        init_constants::Array{T, 1}
        constant_bounds::Array{Bound{T}, 1}
        layer_function::Func{T}

        function Layer{T, N, O}(const_size::Int, const_initializer::Initializer.Func{T}, layer_function::Func{T}) where {T, N, O}
            init_constants = Array{T}(undef, const_size)
            constant_bounds = Array{Bound{T}}(undef, const_size)
            for i in 1:length(init_constants)
                res = const_initializer(i)
                init_constants[i] =  res[1]
                constant_bounds[i] = res[2]
            end
            new{T, N, O}(init_constants, constant_bounds, layer_function)
        end
    end

    struct InternalLayer{T, N ,O}
        const_length::Int
        layer_function::Func{T}
        outputs::Array{T, 1}

        InternalLayer{T}(l::Layer{T, N, O}) where {T, N, O} = new{T, N, O}(length(l.init_constants), l.layer_function, zeros(T, N))

        function (l::InternalLayer{T, N, O})(constant_pointer::APtr{T}, inputs::Array{T, 1}) where {T, N, O}
            l.layer_function(constant_pointer, inputs, l.outputs)
            increment!(constant_pointer, l.const_length)
            return l.outputs
        end
    end

    include("Functional.jl")
    include("Node.jl")
    include("NodeSetLayer.jl")
    include("UniformNodeSetLayer.jl")
    include("ConvolutionalLayer.jl")
end

