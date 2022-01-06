module Layers
    using ..HyperSphere
    import ..Initializer
    import ...AbstractObject

    #Designed for passing around a layer function generator from a given input size  
    #Should be able to make multiple copies (ie the copies are independent of one another)
    @Fun(LayerGenerator, LayerDesign, ProgramBuilder::ProgramBuilder, Settings::MemorySettings, Input_Shape)

    #Initialize all pre allocated arrays
    @Fun(LayerInitializer, Function, InputArray::AbstractArray, OutputArray::AbstractArray, Constants::AbstractArray)

    export LayerDesign

    struct LayerDesign
        sig::Signature
        input_shape
        output_shape
        const_count::Int
        const_initializer
        layer_func::LayerInitializer

        LayerDesign(sig, input_shape, output_shape, const_count, 
            const_initializer, layer_init) = new(sig, input_shape, output_shape, const_count, const_initializer, layer_init)
    end

    include("Dense.jl")
    include("Convolutional.jl")
    include("Softmax.jl")
    include("Reshape.jl")
end

