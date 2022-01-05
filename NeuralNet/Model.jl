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

@VFun(CompiledModelFunction)

mutable struct ModelDesigner{StorageType} <: AbstractObject
    layers::Vector{Layers.Layer}
    error_function::Error.Func

    constants::Vector{StorageType}
    constant_range

    postprocessor::Processor.Func

    last_output_shape
    memsett::MemorySettings

   function ModelDesigner(; input_shape, settings=MemorySettings(), error::Error.Func = Error.None(),
                        postprocessor::Processor.Wrapper=Processor.None(), 
                        constant_range = -1.0:.001:1.0)

        return new{sett.storagetype}(   
            error,
            Vector{storagetype}(undef, 0), #Init the Constant Vector,
            constant_range,
            postprocessor(storagetype, inputtype, outputtype, Array, :CPU),  #Unwrap the postprocessor with the outputtype
            input_shape,
            settings)
   end

    function (d::ModelDesigner{S, I, O, D, A})() where {S, I, O, D, A}
        (length(d.layers) == 0) && return nothing
        constants = alloc(d.constants, D)
        
        last_constant_idx = 1
        fun = nothing
        top_input_array = nothing
        last_output_array = nothing

        for layer in d.layers
            if fun !== nothing
                layer_gen = layer.layer_gen
                
                fun = fun()
            end
        end

        last_constant_idx += l.const_count

        return Model(d, fun, constants, d.constant_range, top_input_array, last_output_array)
    end

    
    "Layer that is repeated accross the last dimension "
    function cylinderlayercount(last_shape, next_shape)
        (length(last_shape) == length(next_shape) - 1) || return 0
        for i in 1:length(last_shape)
            (last_shape[i] == next_shape[i]) || return 0
        end
        return next_shape[end]
    end

    "Layer that matches another layer shape"
    matchlayercount(last_shape, next_shape) = last_shape == next_shape ? 1 : 0

    "Single Element Operation Layer"
    elementwisecount(last_shape, next_shape) = (length(last_shape) == 1 && last_shape[1] == 1) ? ∏(next_shape) : 0
    
    check_layer_shape(last_shape, next_shape) = matchlayercount(last_shape, next_shape) != 0 || elementwisecount(last_shape, next_shape) != 0 || cylinderlayercount(last_shape, next_shape) != 0

    function prepare_layer(designer::ModelDesigner{S, I, O, D}, layer::Layers.Layer) where {S, I, O, D}
        #Dim Check
        (check_layer_shape(designer.last_output_shape, layer.input_shape)) || error("Incorrect Dimensions at Layer:$(length(designer.layers)).
                 Last Output Shape:$(designer.last_output_shape). Recieved:$(layer.input_shape)")

        designer.last_output_shape = layer.output_shape
        
        push!(designer.layers, layer)
        initializer = l.const_initializer !== nothing ? l.const_initializer(ST) : nothing

        count = matchlayercount(last_shape, next_shape)
        (count == 0) && (count = elementwisecount(last_shape, next_shape))
        (count == 0) && (count = cylinderlayercount(last_shape, next_shape))
        
        for i in 1:count
            for c in 1:l.const_count
                res = initializer(c)
                push!(designer.constants, res[1])
            end
        end
    end

    function Base.push!(designer::ModelDesigner{S, I, O, D, A}, layers::Layer...) where {S, I, O, D}
        for layer in layer_wrappers 
            prepare_layer(designer, layer)
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

struct Model{StorageArray, InputArray} <: AbstractObject
    layer_function::CompiledModelFunction
    constants::StorageArray
    constant_range
    error_function::Error.Func
    inputArray::InputArray
    outputArray::InputArray
    postprocessor::Processor.Func
    memsettings::MemorySettings

    Model(designer::ModelDesigner{S, I, O, D, A}, layer_function, constants, constant_range, inputArray, outputArray) where {SA, IA} = 
        new{S, I, O, D, A}(
                  layer_function, 
                  constants, 
                  constant_range,
                  designer.error_function,
                  inputArray,
                  outputArray,
                  designer.postprocessor,
                  designer.memsettings)
    

    function (f::Model{S, I, O, D, A})(args::AbstractArray{I}) where {S, I, O, D, A}
        copy!(f.inputArray, args)                      #Copy to the stored top layer inputArray
        f.layer_function()                             #Run the layers
        out = zeros(I, length(f.outputArray))          #Initialize empty array with input type and length of the output
        copy!(out, f.outputArray)                      #Copy from the last layer to the new out cpu array
        return f.postprocessor(out)                    #Perform processing on the new cpu array and return
    end

    Functions.trainer(f::Model; optimizer::MemoryWrapper{Optimizer.Func} = Optimizer.blackboxoptimizer()) = ModelTrainer(f, optimizer)

    function Base.string(x::Model)
        layerz = join([string(layer) for layer in x.layers], ", ")
        const_count = length(x.constants)
        err_func = x.error_function
        return "Model:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
    end
end

struct ModelTrainer{StorageType, InputType, OutputType, Device, DeviceArray} <: AbstractTrainer{InputType, -1}
        net::Model{StorageType, InputType, OutputType, Device, DeviceArray}
        optimizer::Optimizer.Func{StorageType, OutputType}

        ModelTrainer(net::Model{S, I, O, D, A}, optimizer::MemoryWrapper{Optimizer.Func}) where {S, I, O, D, A} = new{S, I, O, D, A}(net, optimizer(net.memsettings))

        function Base.string(x::ModelTrainer)
                layerz = join([string(layer) for layer in x.net.layers], ", ")
                const_count = length(x.net.constants)
                err_func = x.net.error_function
                return "ModelTrainer:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
        end
end

function Functions.train!(f::ModelTrainer{S, I, O, D, A}, data::AbstractDataSet{I, O}; epochs::Int = 1, IsVerbose=true, testset::AbstractDataSet{I, O}=data) where {S, I, O, D, A}
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

