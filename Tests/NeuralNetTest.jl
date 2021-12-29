include("../HyperSphere.jl")

using .HyperSphere
import .HyperSphere.Functions.Optimizer
import .HyperSphere.Functions.NeuralNet.Layers
import .HyperSphere.Functions.NeuralNet.Layers.Nodes
import .HyperSphere.Functions.NeuralNet.Layers.Functional
import .HyperSphere.Functions.NeuralNet.Activation
import .HyperSphere.Functions.NeuralNet.Initializer
import .HyperSphere.Functions.Error

f(x) = 5 * x ^ 2 + x + sin(x)

function collect_data()
    size = 100
    inputs = zeros(Double, size)
    outputs = zeros(Double, size)
    for i in 1:size
        inputs[i] = i
        outputs[i] = f(i)
    end
    TrainAndTestSplit(Data.ReadArrayToDataSet(inputs, outputs); trainFrac = .8, sort_randomly = true)
end

function test()
    designer = NeuralNet.ModelDesigner(1, 1, error = Error.Meanabserr())
    rng_init = Initializer.RNG(-10.0:10.0)
    push!(designer, Layers.UniformNodeSetLayer(1, 5, Nodes.VarRationalNode(num_terms = 5, denom_terms = 5), rng_init))
    push!(designer, Layers.UniformNodeSetLayer(3, 1, Nodes.LinearNode(functional = Functional.∑()), rng_init))
    neuralnet = designer()
    nettrainer = trainer(neuralnet, optimizer = Optimizer.blackboxoptimizer())
    data = collect_data()
    println("Pre Training Test: f(3.0) = $(f(3.0)). Neural Net:$(neuralnet([3.0])[1])")
    train!(nettrainer, data[1]; epochs = 1, testset = data[2])
    println("After Training Test: f(3.0) = $(f(3.0)). Neural Net:$(neuralnet([3.0])[1])")
end


test()


