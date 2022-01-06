export ModelDesigner

struct LayerDetails
    design::LayerDesign
    input_shape
    output_shape

    input_ptr::PrealloctionPointer
    output_ptr::PrealloctionPointer

    function LayerDetails{S}(layer::LayerDesign, pb::ProgramBuilder, initial_constants) where S
        #Allocate memory for layer input and output
        input_ptr = prealloc_stack!(pb, S, prod(layer.input_shape))
        output_ptr = prealloc_stack!(pb, S, prod(layer.output_shape))

        initializer = layer.const_initializer !== nothing ? layer.const_initializer(S) : nothing

        for c in 1:l.const_count
            push!(initial_constants, initializer(c))
        end                

        new(layer, )
    end
end

mutable struct ModelDesigner{StorageType} <: AbstractObject
    layers::Vector{Array{Layers.LayerDetails}}
    initial_constants::Vector{StorageType}
    error_function::Error.Func
    constant_range
    postprocessor::Processor.Func
    last_output_shape
    memsett::MemorySettings
    pb::ProgramBuilder
    was_built::Bool
    

   function ModelDesigner(; input_shape, settings=MemorySettings(), error::Error.Func = Error.None(),
                        postprocessor::Processor.Wrapper=Processor.None(), 
                        constant_range = -1.0:.001:1.0)

        return new{settings.storagetype}(   
            Vector{Layers.LayerDetails}(undef, 0)
            error,
            constant_range,
            postprocessor(settings),
            input_shape,
            settings,
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
        input_array = 

        program = pb()
        constants = constants()
        copy!(constants, d.initial_constants)

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
    function prepare_layer(designer::ModelDesigner{S}, layer::Layers.LayerDesign) where S
        #Dim Check
        (check_layer_shape(designer.last_output_shape, layer.input_shape)) || error("Incorrect Dimensions at Layer:$(length(designer.layers)).
                 Last Output Shape:$(designer.last_output_shape). Recieved:$(layer.input_shape)")

        designer.last_output_shape = layer.output_shape

        count = matchlayercount(last_shape, next_shape)
        (count == 0) && (count = elementwisecount(last_shape, next_shape))
        (count == 0) && (count = cylinderlayercount(last_shape, next_shape))
        push!(designer.layers, layer)
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