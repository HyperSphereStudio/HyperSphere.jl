import ..Error
import ..Layer
import ..Optimizer
import ...AbstractObject

export ModelDesigner, Model

mutable struct ModelDesigner{T, InputDim, OutputDim} <: AbstractObject
    layers::Vector{Layers.InternalLayer}
    init_constants::Vector{T}
    constant_bounds::Vector{Bound{T}}
    error_function::Error.Func{T}

    ModelDesigner{T, I, O}(error_function::Error.Func{T}) where {T, I, O} = 
        new{T, I, O}(
            Vector{Layers.Layer}(undef, 0),
            zeros(T, 0),
            Vector{Bound{T}}(undef, 0), error_function)

    (d::ModelDesigner)() = Model(d)

    function Base.push!(designer::ModelDesigner{T, I, O}, layer::Layers.Layer{T}) where {T, I, O}
        push!(designer.layers, Layers.InternalLayer{T}(layer))
        append!(designer.init_constants, layer.init_constants)
        append!(designer.constant_bounds, layer.constant_bounds)
    end

    function Base.string(x::ModelDesigner)
        layerz = join([string(layer) for layer in x.layers], ", ")
        const_count = length(x.init_constants)
        err_func = x.error_function
        return "ModelDesigner:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
    end
end

struct Model{T, InputDim, OutputDim} <: AbstractObject
    layers::Array{Layers.InternalLayer}
    constants::ConstantPool{T}
    constant_bounds::Array{Bound{T}}
    error_function::Error.Func{T}

    Model(designer::ModelDesigner{T, I, O}) where {T, I, O} = 
        new{T, I, O}(designer.layers, 
                    Array(designer.init_constants), 
                    Array(designer.constant_bounds), 
                    designer.error_function)
    

    function (f::Model{T, I, O})(args::AbstractArray{T}) where {T, I, O}
            const_ptr = APtr(f.constants)
            for l in f.layers
                    args = l(const_ptr, args)
            end
            args
    end

    Functions.trainer(f::Model; precision=10) = ModelTrainer(f)

    function Base.string(x::Model)
        layerz = join([string(layer) for layer in x.layers], ", ")
        const_count = length(x.constants)
        err_func = x.error_function
        return "Model:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
    end
end

struct ModelTrainer{T, I, O} <: AbstractTrainer{T, I}
        net::Model{T, I, O}

        ModelTrainer(net::Model{T, I, O}) where {T, I, O} = new{T, I, O}(net)

        function Functions.train!(f::ModelTrainer{T, I, O}, data::AbstractDataSet, optimizer::Optimizer.Func{T}; DataType::Type=T)  where {T, I, O}
                iter = Iterable(data)
                copy!(f.net.constants, optimizer(f.net.constants, 
                function (constants)
                        copy!(f.net.constants, constants)
                        f.net.error_function(iter, DataType)
                end, f.net.constant_bounds))
        end

        function Base.string(x::ModelTrainer)
                layerz = join([string(layer) for layer in x.net.layers], ", ")
                const_count = length(x.net.constants)
                err_func = x.net.error_function
                return "ModelTrainer:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
        end
end



