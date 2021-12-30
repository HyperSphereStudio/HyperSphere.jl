module Layers
    using ..Utils
    import ..Initializer
    import ...AbstractObject

    @VFun(Func{StorageType, InputType, OutputType}, constant_pointer::APtr{StorageType}, inputs::APtr{InputType}, outputs::APtr{OutputType})
    @Fun(Wrapper, layer::AbstractObject, StorageType::Type, InputType::Type, OutputType::Type)

    export Layer, InternalLayer

    mutable struct Layer{ST, IT, OT, N, O} <: AbstractObject
        init_constants::Array{ST, 1}
        constant_bounds::Array{Bound{ST}, 1}
        layer_function::Func{ST, IT, OT}

        function Layer{ST, IT, OT, N, O}(const_size::Int, const_initializer, layer_function::Func{ST, IT, OT}) where {ST, IT, OT, N, O}
            init_constants = Array{ST}(undef, const_size)
            constant_bounds = Array{Bound{ST}}(undef, const_size)
            initializer = const_initializer !== nothing ? const_initializer(ST) : nothing
            for i in 1:length(init_constants)
                res = initializer(i)
                init_constants[i] =  res[1]
                constant_bounds[i] = res[2]
            end
            new{ST, IT, OT, N, O}(init_constants, constant_bounds, layer_function)
        end

        Base.string(x::Layer{ST, IT, OT, N, O}) where {ST, IT, OT, N, O} = "Layer{$ST, $IT, $OT, $N, $O}(Const_Count=$(size(x.init_constants)), Layer_Fun=$(x.layer_function))"
    end

    struct InternalLayer{ST, IT, OT, N ,O} <: AbstractObject
        const_length::Int
        layer_function::Func{ST, OT}
        outputs::APtr{OT}

        InternalLayer(l::Layer{ST, IT, OT, N, O}) where {ST, IT, OT, N, O} = new{ST, IT, OT, N, O}(length(l.init_constants), l.layer_function, APtr(zeros(OT, O)))

        function (l::InternalLayer{ST, IT, OT, N, O})(constant_pointer::APtr{ST}, inputs::APtr{IT}) where {ST, IT, OT, N, O}
            l.layer_function(constant_pointer, inputs, l.outputs)
            return l.outputs
        end

        Base.string(x::InternalLayer{ST, IT, OT, N, O}) where {ST, IT, OT, N, O} = "Layer{$ST, $IT, $OT, $N, $O}(Const_Count=$(x.const_length), Layer_Fun=$(x.layer_function))"
    end

    include("Functional.jl")
    include("Node.jl")
    include("NodeSetLayer.jl")
    include("UniformNodeSetLayer.jl")
    include("ConvolutionalLayer.jl")
    include("SoftmaxLayer.jl")
end

