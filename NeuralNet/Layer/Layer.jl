module Layers
    using ..HyperSphere
    import ..Initializer
    import ...AbstractObject

    #Designed for passing around a layer function generator from a given input size  
    #Should be able to make multiple copies (ie the copies are independent of one another)
    @Fun(ParallelWrapper, LayerDesign, Settings::MemorySettings, Input_Shape)
    
    #Designed to be a unqiue layer generator that takes in a certain input and output
    @Fun(Generator, Function, Inputs::AbstractArray, Outputs::AbstractArray, Constants::AbstractArray)

    export LayerDesign

    struct LayerDesign
        input_shape
        output_shape
        const_count::Int
        const_initializer
        sig::Signature
        layer_gen::Generator

        LayerDesign(sig, input_shape, output_shape, const_count, const_initializer, layer_gen) = new(input_shape, output_shape, const_count, const_initializer, sig, layer_gen)
    end

    include("DenseLayer.jl")
    include("ConvolutionalLayer.jl")
    include("SoftmaxLayer.jl")
    include("ReshapeLayer.jl")
end

