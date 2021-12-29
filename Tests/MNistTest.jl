include("../HyperSphere.jl")

using .HyperSphere
import .HyperSphere.Functions.Optimizer
import .HyperSphere.Functions.NeuralNet.Layers
import .HyperSphere.Functions.NeuralNet.Layers.Nodes
import .HyperSphere.Functions.NeuralNet.Layers.Functional
import .HyperSphere.Functions.NeuralNet.Activation
import .HyperSphere.Functions.NeuralNet.Initializer
import .HyperSphere.Functions.Error

include("../DataSets/MNIST/MNistDataSet.jl")

function test()
    designer = NeuralNet.ModelDesigner(28 * 28, 1, error = Error.Meanabserr())
    rng_init = Initializer.RNG(-10.0:10.0)
    
    

    neuralnet = designer()
    nettrainer = trainer(neuralnet, optimizer=Optimizer.blackboxoptimizer())

    trainingData = randombatch(MNistDataSet(true), 50)

    train!(nettrainer, trainingData; epochs=1)
end

test()