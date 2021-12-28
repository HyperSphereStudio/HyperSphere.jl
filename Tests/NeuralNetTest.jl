include("../HyperSphere.jl")

using .HyperSphere
import .HyperSphere.Functions.Optimizer
import .HyperSphere.Functions.NeuralNet.Layers
import .HyperSphere.Functions.NeuralNet.Layers.Nodes
import .HyperSphere.Functions.NeuralNet.Layers.Functional
import .HyperSphere.Functions.NeuralNet.Activation
import .HyperSphere.Functions.NeuralNet.Initializer
import .HyperSphere.Functions.Error

f(x) = 5 * x

function collect_data()
    data_size = 100
    inputs = zeros(Double, data_size)
    outputs = zeros(Double, data_size)
    
    for i in 1:data_size
        inputs[i] = i
        outputs[i] = f(i)
    end

    Data.ReadArrayToDataSet(inputs, outputs)
end

function test()
    designer = NeuralNet.ModelDesigner(1, 1, error = Error.Meanabserr())

    rng_init = Initializer.RNG(-10.0:10.0)

    push!(designer, Layers.UniformNodeSetLayer(1, 5, Nodes.LinearNode(), rng_init))
    push!(designer, Layers.UniformNodeSetLayer(3, 1, Nodes.LinearNode(functional = Functional.∑()), rng_init))

    neuralnet = designer()
    nettrainer = trainer(neuralnet, optimizer = Optimizer.blackboxoptimizer())
    
    println(join(["$i=$(round(neuralnet([i])[1], digits=3))" for i in 1.0:10.0], ","))
    train!(nettrainer, collect_data())
    println(join(["$i=$(round(neuralnet([i])[1], digits=3))" for i in 1.0:10.0], ","))
end


test()


