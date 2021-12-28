include("../HyperSphere.jl")

using .HyperSphere
import .HyperSphere.Functions.Optimizer
import .HyperSphere.Functions.NeuralNet.Layers
import .HyperSphere.Functions.NeuralNet.Layers.Nodes
import .HyperSphere.Functions.NeuralNet.Layers.Functional
import .HyperSphere.Functions.NeuralNet.Activation
import .HyperSphere.Functions.NeuralNet.Initializer
import .HyperSphere.Functions.Error

function collect_data()
    inputs = zeros(Double, 10)
    outputs = zeros(Double, 10)
    
    for i in 1:10
        inputs[i] = i
        outputs[i] = i * 2
    end

    Data.ReadArrayToDataSet(inputs, outputs)
end

function test()
    designer = NeuralNet.ModelDesigner(1, 1, error = Error.Meansqrerr())

    rng_init = Initializer.RNG(-10.0:10.0)

    push!(designer, Layers.UniformNodeSetLayer(1, 5, Nodes.LinearNode(activation = Activation.Tanh()), rng_init))
    push!(designer, Layers.UniformNodeSetLayer(5, 1, Nodes.LinearNode(functional = Functional.∑()), rng_init))

    neuralnet = designer()
    nettrainer = trainer(neuralnet, optimizer = Optimizer.blackboxoptimizer(method = :de_rand_1_bin))
    
    println("Pre Train:" * join(["$i=$(neuralnet([i]))" for i in 1.0:10.0], ", "))
    train!(nettrainer, collect_data())
    println("Post Train:" * join(["$i=$(neuralnet([i]))" for i in 1.0:10.0], ", "))
end


test()


