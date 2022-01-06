#Written By Johnathan Bizzano

include("../NeuralNetTest.jl")

#Hyperparameters
const train_sample_size = 10
const test_sample_size = 10
const iterations = 5
const scalefactor = .8
const crossoverrate = .7
const population_size = 10
const IsVerbose = true

const InputType = Float32
const StorageType = Float32

function MNistDataSet(isTrainingData::Bool; T::Type = InputType)
    isTrainingData && return LazyDataSet(Data.Reader{T, 28 ^ 2, 1}(row -> 
        DataEntry{T, 28^2, 1}(MNIST.traintensor(T, row), Array([T(MNIST.trainlabels(row))]))), 60000)
    return LazyDataSet(Data.Reader{T, 28 ^ 2, 1}(row -> 
        DataEntry{T, 28^2, 1}(MNIST.testtensor(T, row), Array([T(MNIST.testlabels(row))]))), 10000)
end

function test()

    argMaxAndSubtractOne = Processor.Chain(Processor.SingleFunc(Single.Add(-1)), Processor.ArgMaxIdx())

    designer = NeuralNet.ModelDesigner(input_size=28^2, inputtype=InputType, outputtype=InputType, 
                                    storagetype=StorageType, output_size=1, error = Error.Meanabserr(), 
                                    postprocessor = argMaxAndSubtractOne)

    
    rng_init = Initializer.RNG(-1.0:.001:1.0)

    NeuralNet.rpush!(designer, 
            Layers.ConvolutionalLayer2D(rng_init; inputdims=(28, 28), outputdims=(28, 28), kerneldims = (3,3)),
            Layers.MaxPoolingLayer2D(; inputdims=(28, 28), outputdims=(28, 28), kerneldims = (2,2))
            repeat = 28)
    
    push!(designer, Layers.UniformNodeSet(rng_init, Nodes.Weight(; functional=Functional.∑(; dropoutprob = .2)), input_size=28^2, output_size=128))
    push!(designer, Layers.SoftmaxLayer(; size = 10))

    neuralnet = designer()
    nettrainer = trainer(neuralnet, optimizer=Optimizer.de_rand_1_bin(; population_size = population_size, 
                        iterations = iterations, scalefactor = scalefactor, crossoverrate = crossoverrate, IsVerbose = IsVerbose))

    trainingData = RandomBatch(MNistDataSet(true), train_sample_size)
    testData = RandomBatch(MNistDataSet(false), test_sample_size)

    for i in 1:10
        entry = trainingData[i]
        output = neuralnet(entry.inputs)[1]
        real = entry.outputs[1]
        println("Test #$i. Actual:$real. Predicted:$output")
    end

    train!(nettrainer, trainingData; epochs=1, IsVerbose = IsVerbose, testset = testData)

    for i in 1:10
        entry = trainingData[i]
        output = neuralnet(entry.inputs)[1]
        real = entry.outputs[1]
        println("Test #$i. Actual:$real. Predicted:$output")
    end
end

test()