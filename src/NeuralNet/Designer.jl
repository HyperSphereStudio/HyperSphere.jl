export ModelDesigner

using ...Layer

struct LayerDetails
    design::LayerDesign
    input_ptr::PrealloctionPointer
    output_ptr::PrealloctionPointer
    const_idx

    function LayerDetails(layer::LayerDesign, pb::ProgramBuilder, initial_constants)
        S = pb.device.storagetype
        initializer = layer.const_initializer !== nothing ? layer.const_initializer(S) : nothing
        const_idx = length(initial_constants) + 1
        
        for c in 1:prod(l.const_shape)
            push!(initial_constants, initializer(c))
        end                

        new(layer, prealloc_stack!(pb, S, layer.input_shape...), prealloc_stack!(pb, S, layer.output_shape...), const_idx)
    end
end

mutable struct ModelDesigner{StorageType} <: AbstractObject
    layers::Vector{LayerDetails}
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
        program = pb()
        constants = constants()
        copy!(constants, d.initial_constants)
        fun = (inputs) -> copy!(layer_inputs, inputs)
        last_output_array = nothing

        for layer in d.layers
            layer_inputs = layer.input_ptr() 
            layer_outputs = layer.input_ptr()
            layer_const_shape = layer.design.const_shape
            layer_constants = reshape(view(constants, layer.const_idx:(layer.const_idx + prod(layer_const_shape))), layer_const_shape...)
            layer_fun = layer(layer_inputs, layer_outputs, layer_constants)
            last_output_array = layer_outputs

            fun = function (inputs)
                    fun(inputs)
                    layer_fun()
                  end 
        end
        
        proc = d.postprocessor
        fun = function (inputs)
             fun(inputs)
             return proc(layer_outputs)
        end 
        
        return Model(d, fun, program, constants, d.constant_range, d.settings.arrayType{d.settings.inputType}, d.settings.outputType)
    end
    
    "Do dimension checking and constant initializing"
    function prepare_layer(designer::ModelDesigner{S}, layer::Layers.LayerDesign) where S
        is_reshape_layer = layer.sig.name == :ReshapeLayer
        ((designer.last_output_shape !=  layer.input_shape) || is_reshape_layer) || error("Incorrect Dimensions at Layer:$(length(designer.layers)).
                 Last Output Shape:$(designer.last_output_shape). Recieved:$(layer.input_shape)")
        is_reshape_layer || push!(designer.layers, LayerDetails(layer, designer.pb, designer.initial_constants))
        designer.last_output_shape = layer.output_shape
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