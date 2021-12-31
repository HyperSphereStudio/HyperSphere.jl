include("../HyperSphere.jl")

#Written By Johnathan Bizzano
using .HyperSphere
import .HyperSphere.Functions.Optimizer
import .HyperSphere.Functions.NeuralNet.Layers
import .HyperSphere.Functions.NeuralNet.Layers.Nodes
import .HyperSphere.Functions.NeuralNet.Layers.Functional
import .HyperSphere.Functions.NeuralNet.Activation
import .HyperSphere.Functions.NeuralNet.Initializer
import .HyperSphere.Functions.Error

using MLDatasets


function MNistDataSet(isTrainingData::Bool; T::Type = Float32)
    isTrainingData && return LazyDataSet(Data.Reader{T, 28 ^ 2, 1}(row -> 
        DataEntry{T, 28^2, 1}(tuple(MNIST.traintensor(T, row)..., ), tuple(T(MNIST.trainlabels(row))))), 50, 60000)
    return LazyDataSet(Data.Reader{T, 28 ^ 2, 1}(row -> 
        DataEntry{T, 28^2, 1}(tuple(MNIST.testtensor(T, row)..., ), tuple(T(MNIST.testlabels(row))))), 50, 10000)
end

function test()
    designer = NeuralNet.ModelDesigner(input_size=28^2, inputtype=Float32, outputtype=Float32, 
                                    storagetype=Float32, output_size=1, error = Error.Meanabserr())

    rng_init = Initializer.RNG(-100.0:.1:100.0)
    
    push!(designer, Layers.ConvolutionalLayer2D(rng_init; inputdims=(28, 28), outputdims=(28,28), kernaldims = (4,4)))
    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.NoneNode(; activation=Activation.RELU(), functional=Functional.None()), input_size=28^2, output_size=28^2))
    push!(designer, Layers.MaxPoolingLayer2D(; inputdims=(28, 28), outputdims=(20,20), kernaldims = (4,4)))
    
    push!(designer, Layers.ConvolutionalLayer2D(rng_init; inputdims=(18, 18), outputdims=(18,18), kernaldims = (4,4)))
    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.NoneNode(; activation=Activation.RELU(), functional=Functional.None()), input_size=18^2, output_size=18^2))
    push!(designer, Layers.MaxPoolingLayer2D(; inputdims=(18, 18), outputdims=(8, 8), kernaldims = (4,4)))

    push!(designer, Layers.ConvolutionalLayer2D(rng_init; inputdims=(8, 8), outputdims=(8,8), kernaldims = (4,4)))
    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.NoneNode(; activation=Activation.RELU(), functional=Functional.None()), input_size=8^2, output_size=8^2))
    push!(designer, Layers.MaxPoolingLayer2D(; inputdims=(8, 8), outputdims=(5, 5), kernaldims = (4,4)))

    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.LinearNode(; activation=Activation.Tanh(), functional=Functional.∑()), input_size=5^2, output_size=100))
    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.LinearNode(; activation=Activation.Tanh(), functional=Functional.∑()), input_size=100, output_size=100))
    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.LinearNode(; activation=Activation.Tanh(), functional=Functional.∑()), input_size=100, output_size=100))
    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.LinearNode(; activation=Activation.Tanh(), functional=Functional.∑()), input_size=100, output_size=10))
    push!(designer, Layers.SoftmaxLayer(rng_init; size = 10))
    push!(designer, Layers.UniformNodeSetLayer(rng_init, Nodes.LinearNode(; activation=Activation.None(), functional=Functional.argmaxidx()), input_size=1, output_size=1))

    neuralnet = designer()
    nettrainer = trainer(neuralnet, optimizer=Optimizer.de_rand_1_bin(; population_size = 10, iterations = 50, scalefactor = .8, crossoverrate = .7))

    trainingData = randombatch(MNistDataSet(true), 50)
    testData = randombatch(MNistDataSet(false), 50)

    train!(nettrainer, trainingData; epochs=1, IsVerbose = true, testset = testData)
end

test()