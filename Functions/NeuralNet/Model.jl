import ..Error
import ..Layer
import ..Optimizer
import ...AbstractObject
import ...Double
import ..Initializer


export ModelDesigner, Model

mutable struct ModelDesigner{StorageType, InputType, OutputType, InputSize, OutputSize} <: AbstractObject
    layers::Vector{Layers.InternalLayer}
    init_constants::Vector{StorageType}
    constant_bounds::Vector{Bound{StorageType}}
    error_function::Error.Func{OutputType}

    ModelDesigner(input_size::Int, output_size::Int; storagetype::Type = Double, inputtype::Type = Double, outputtype::Type = Double, error::Error.Wrapper = Error.None()) = 
        new{storagetype, inputtype, outputtype, input_size, output_size}(
            Vector{Layers.Layer}(undef, 0),
            zeros(storagetype, 0),
            Vector{Bound{storagetype}}(undef, 0), error(inputtype, outputtype))

    (d::ModelDesigner)() = Model(d)

    function Base.push!(designer::ModelDesigner{ST, IT, OT, I, O}, layer_wrapper::Layers.Wrapper) where {ST, IT, OT, I, O}
        layer = layer_wrapper(ST, IT, OT)
        push!(designer.layers, Layers.InternalLayer(layer))
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

struct Model{StorageType, InputType, OutputType, InputSize, OutputSize} <: AbstractObject
    layers::Array{Layers.InternalLayer}
    constants::ConstantPool{StorageType}
    constant_bounds::Array{Bound{StorageType}}
    error_function::Error.Func{StorageType}

    Model(designer::ModelDesigner{ST, IT, OT, I, O}) where {ST, IT, OT, I, O} = 
        new{ST, IT, OT, I, O}(designer.layers, 
                    Array(designer.init_constants), 
                    Array(designer.constant_bounds), 
                    designer.error_function)
    
    function (f::Model{ST, IT, OT, I, O})(args::NTuple{I, IT}) where {ST, IT, OT, I, O}
        a = Array{IT, 1}(undef, I)
        for i in 1:length(args)
            a[i] = args[i]
        end
        return f(a)
    end

    function (f::Model{ST, IT, OT, I, O})(args::Array{IT, 1}) where {ST, IT, OT, I, O}
            const_ptr = APtr(f.constants)
            for l in f.layers
                    args = l(const_ptr, args)
            end
            args
    end

    Functions.trainer(f::Model; optimizer::Optimizer.Wrapper = Optimizer.blackboxoptimizer()) = ModelTrainer(f, optimizer)

    function Base.string(x::Model)
        layerz = join([string(layer) for layer in x.layers], ", ")
        const_count = length(x.constants)
        err_func = x.error_function
        return "Model:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
    end
end

struct ModelTrainer{StorageType, InputType, OutputType, InputSize, OutputSize} <: AbstractTrainer{InputType, InputSize}
        net::Model{StorageType, InputType, OutputType, InputSize, OutputSize}
        optimizer::Optimizer.Func{StorageType, OutputType}


        ModelTrainer(net::Model{ST, IT, OT, I, O}, optimizer::Optimizer.Wrapper) where {ST, IT, OT, I, O} = new{ST, IT, OT, I, O}(net, optimizer(ST, OT))

        function Base.string(x::ModelTrainer)
                layerz = join([string(layer) for layer in x.net.layers], ", ")
                const_count = length(x.net.constants)
                err_func = x.net.error_function
                return "ModelTrainer:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
        end
end

function Functions.train!(f::ModelTrainer{ST, IT, OT, I, O}, data::AbstractDataSet) where {ST, IT, OT, I, O}
    copy!(f.net.constants, f.optimizer(f.net.constants, 
        Error.Func{OT}(
            function (constants)
            copy!(f.net.constants, constants)
            f.net.error_function(data, f.net)
            end), 
        f.net.constant_bounds))
end

