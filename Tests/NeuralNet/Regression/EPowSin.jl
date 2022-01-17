#Written By Johnathan Bizzano

include("../NeuralNetTest.jl")

const sample_size = 100
const iterations = 100
const scalefactor = .8
const crossoverrate = .6
const population_size = 30

const IsVerbose = true
const InputType = Float64
const StorageType = Float64

f(x) = MathConstants.e ^ sin(x)

function collect_data()
    inputs = zeros(Double, sample_size)
    outputs = zeros(Double, sample_size)
    for i in 1:sample_size
        inputs[i] = i
        outputs[i] = f(i)
    end
    TrainAndTestSplit(Data.ReadArrayToDataSet(inputs, outputs); trainFrac=.8, sort_randomly=true)
end

function test()
    designer = NeuralNet.ModelDesigner(input_shape=(1), error=Error.Meanabserr())
    rng_init = Initializer.RNG(-1.0:.01:1.0)
    push!(designer, Layers.Dense(100, rng_init))
    push!(designer, Layers.Dense(100, rng_init))
    push!(designer, Layers.Dense(1, rng_init))
    
    neuralnet = designer()
    nettrainer = trainer(neuralnet, optimizer=Optimizer.de_rand_1_bin(; population_size = population_size,
                     iterations = iterations, scalefactor = scalefactor, crossoverrate = crossoverrate, IsVerbose = IsVerbose))

    data = collect_data()
    println("Pre Training Test: f(3.0) = $(f(3.0)). Neural Net:$(neuralnet([3.0])[1])")
    train!(nettrainer, data[1]; epochs=1, testset=data[2], IsVerbose = IsVerbose)
    println("After Training Test: f(3.0) = $(f(3.0)). Neural Net:$(neuralnet([3.0])[1])")
end


test()


