#Written By Johnathan Bizzano
using ..HyperSphere
import ..Error
import ..Layer
import ..Optimizer
import ...AbstractObject
import ...Double
import ..Initializer
import .Processor

export ModelDesigner, Model, rpush!

mutable struct ModelDesigner{StorageType} <: AbstractObject
    layers::Vector{Layers.LayerDesign}
    error_function::Error.Func
    constant_range
    postprocessor::Processor.Func
    last_output_shape
    memsett::MemorySettings
    initial_constants::Vector{StorageType}
    pb::ProgramBuilder
    was_built::Bool

   function ModelDesigner(; input_shape, settings=MemorySettings(), error::Error.Func = Error.None(),
                        postprocessor::Processor.Wrapper=Processor.None(), 
                        constant_range = -1.0:.001:1.0)

        return new{settings.storagetype}(   
            error,
            constant_range,
            postprocessor(settings),
            input_shape,
            settings,
            Vector{storagetype}(undef, 0),
            ProgramBuilder(d.settings.device),
            false)
   end

    function (d::ModelDesigner{S})() where {S}
        (length(d.layers) == 0) && return nothing
        (d.was_built) && error("Cannot Rebuild from same designer. Please make another")
        d.was_built = true
        
        constants = prealloc_global!(d.pb, :Constants, S, length(d.initial_constants))
        input_shape = d.layers[1].input_shape
        output_shape = d.layers[1].output_shape
        input_array = prealloc_stack!(d.pb, S, prod(d.layers[1].input_shape))

        program = pb()
        constants = constants()
        input_array = input_array()
        input_matrix = reshape(input_array, d.layers[1].input_shape...)

        program.program = function (input)
                                input = program.program(copy(input))
                                (input_shape != size(input)) && error("Invalid Input Shape. Expected:$input_shape. Recieved:$(size(input))")
                                                                
                          end
        
        for layer in d.layers
            count = matchlayercount(last_shape, next_shape)
                if count != 0
                    
                else
                    count = elementwisecount(last_shape, next_shape)
                    if count != 0

                    else
                        count = cylinderlayercount(last_shape, next_shape)
                    end
                end
        end

        
        return Model(d, program, constants, d.constant_range, d.settings.arrayType{d.settings.inputType}, d.settings.outputType)
    end

    
    "Layer that is repeated accross the last dimension "
    cylinderlayercount(last_shape, next_shape) = (last_shape == next_shape[1:(end - 1)]) ? next_shape[end] : 0

    "Layer that matches another layer shape"
    matchlayercount(last_shape, next_shape) = last_shape == next_shape ? 1 : 0

    "Single Element Operation Layer"
    elementwisecount(last_shape, next_shape) = (length(last_shape) == 1 && last_shape[1] == 1) ? prod(next_shape) : 0
    
    check_layer_shape(last_shape, next_shape) = matchlayercount(last_shape, next_shape) != 0 || elementwisecount(last_shape, next_shape) != 0 || cylinderlayercount(last_shape, next_shape) != 0

    "Do dimension checking and constant initializing"
    function prepare_layer(designer::ModelDesigner{S}, layer::Layers.LayerDesign) where {S}
        #Dim Check
        (check_layer_shape(designer.last_output_shape, layer.input_shape)) || error("Incorrect Dimensions at Layer:$(length(designer.layers)).
                 Last Output Shape:$(designer.last_output_shape). Recieved:$(layer.input_shape)")

        designer.last_output_shape = layer.output_shape
        
        push!(designer.layers, layer)
        initializer = l.const_initializer !== nothing ? l.const_initializer(S) : nothing

        count = matchlayercount(last_shape, next_shape)
        (count == 0) && (count = elementwisecount(last_shape, next_shape))
        (count == 0) && (count = cylinderlayercount(last_shape, next_shape))
        
        for i in 1:count
            for c in 1:l.const_count
                res = initializer(c)
                push!(designer.initial_constants, res)
            end
        end
    end

    function Base.push!(designer::ModelDesigner, layer::LayerGenerator)
        prepare_layer(designer, layer(designer.pb, designer.memsett, designer.last_output_shape))
    end

    function Base.append!(designer::ModelDesigner, layers::LayerGenerator...)
        for layer in layers
            push!(designer, layer)
        end
    end


    function Base.string(x::ModelDesigner)
        layerz = join([string(layer) for layer in x.layers], ", ")
        const_count = length(x.init_constants)
        err_func = x.error_function
        return "ModelDesigner:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
    end
end

function rpush!(r::ModelDesigner, items::Layers.Wrapper...; repeat = 1)
    for i in 1:repeat
        push!(r, items...)
    end
end

struct Model{StorageArray, InputType, OutputType} <: AbstractObject
    program::Program
    constants::StorageArray
    constant_range
    error_function::Error.Func
    memsettings::MemorySettings

    Model(designer::ModelDesigner{S}, program, constants, constant_range, InputType, OutputType) where S = 
        new{S, InputType, OutputType}(
                  program, 
                  constants,
                  constant_range,
                  designer.error_function,
                  designer.memsettings)
    

    function (f::Model{S, I, O})(args::I)::O where {S, I, O}
        return f.program(args)
    end

    Functions.trainer(f::Model; optimizer::MemoryWrapper{Optimizer.Func} = Optimizer.blackboxoptimizer()) = ModelTrainer(f, optimizer)

    function Base.string(x::Model)
        layerz = join([string(layer) for layer in x.layers], ", ")
        const_count = length(x.constants)
        err_func = x.error_function
        return "Model:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
    end
end

struct ModelTrainer{StorageType, InputType, OutputType} <: AbstractTrainer{InputType, -1}
        net::Model{StorageType, InputType, OutputType, Device, DeviceArray}
        optimizer::Optimizer.Func{StorageType, OutputType}

        ModelTrainer(net::Model{S, I, O}, optimizer::MemoryWrapper{Optimizer.Func}) where {S, I, O} = new{S, I, O}(net, optimizer(net.memsettings))

        function Base.string(x::ModelTrainer)
                layerz = join([string(layer) for layer in x.net.layers], ", ")
                const_count = length(x.net.constants)
                err_func = x.net.error_function
                return "ModelTrainer:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
        end
end

function Functions.train!(f::ModelTrainer, data::AbstractDataSet; epochs::Int = 1, IsVerbose=true, testset::AbstractDataSet=data)
    t = time()
    err_func = Error.Func2(() -> f.net.error_function(data, f.net))
    test_func = Error.Func2(() -> f.net.error_function(testset, f.net))
    
    if IsVerbose
        println("========MODEL TRAINING STARTED=======")
        println("Initial: Data Error:", err_func(), ". Test Error:", test_func())
        println("Number of Parameters:$(length(f.net.constants))")
    end

    for i in 1:epochs
        res = f.optimizer(f.net.constants, err_func, first(f.net.constant_range), last(f.net.constant_range))
        copy!(f.net.constants, res[1])
        reset(data)
        if IsVerbose
            println("Epoch:$i. Took (", time() - t, ") seconds. Data Error:", res[2], ". Test Error:", test_func())
            t = time()
        end
    end

    if IsVerbose
        println("========MODEL TRAINING ENDED=======")
    end

    (err_func(), test_func())
end

