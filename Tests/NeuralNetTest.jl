include("../HyperSphere.jl")

using .HyperSphere
import .HyperSphere.Functions.Error
import .HyperSphere.Functions.Optimizer
import .HyperSphere.Functions.NeuralNet.Layers
import .HyperSphere.Functions.NeuralNet.Layers.Nodes
import .HyperSphere.Functions.NeuralNet.Layers.Functional
import .HyperSphere.Functions.NeuralNet.Initializer

function collect_data()
    inputs = zeros(Float64, 10)
    outputs = zeros(Float64, 10)
    
    for i in 1:10
        inputs[i] = i
        outputs[i] = i * 2
    end

    Data.ReadArrayToDataSet(inputs, outputs)
end

function test()
    designer = NeuralNet.ModelDesigner{Float64, 1, 1}(Error.meansqrerr(Float64))

    push!(designer, Layers.UniformNodeSetLayer(Float64, 1, 5, Nodes.LinearNode(Float64), Initializer.RNGInitializer(Float64, -5.0:5.0)))
    push!(designer, Layers.UniformNodeSetLayer(Float64, 5, 1, Nodes.LinearNode(Float64), Initializer.RNGInitializer(Float64, -5.0:5.0)))

    neuralnet = designer()
    nettrainer = Functions.trainer(neuralnet)
    train!(nettrainer, collect_data(), Optimizer.blackboxoptimizer(MemoryDataSet, Float64))
    println(nettrainer)
    println(designer)
    println(neuralnet([2.0]))
end


test()


