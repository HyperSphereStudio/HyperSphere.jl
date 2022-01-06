#Written By Johnathan Bizzano
using ..HyperSphere
import ..Error
import ..Layer
import ..Optimizer
import ...AbstractObject
import ...Double
import ..Initializer
import .Processor

export Model

struct Model{StorageArray, InputType, OutputType} <: AbstractObject
    program::Program
    constants::StorageArray
    constant_range
    error_function::Error.Func
    memsettings::MemorySettings

    Model(designer::ModelDesigner{S}, program, constants, constant_range, InputType, OutputType) where S = 
        new{S, InputType, OutputType}(
                  program, 
                  constants,
                  constant_range,
                  designer.error_function,
                  designer.memsettings)
    

    function (f::Model{S, I, O})(args::I)::O where {S, I, O}
        return f.program(args)
    end

    Functions.trainer(f::Model; optimizer::MemoryWrapper{Optimizer.Func} = Optimizer.blackboxoptimizer()) = ModelTrainer(f, optimizer)

    function Base.string(x::Model)
        layerz = join([string(layer) for layer in x.layers], ", ")
        const_count = length(x.constants)
        err_func = x.error_function
        return "Model:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
    end
end

struct ModelTrainer{StorageType, InputType, OutputType} <: AbstractTrainer{InputType, -1}
        net::Model{StorageType, InputType, OutputType, Device, DeviceArray}
        optimizer::Optimizer.Func{StorageType, OutputType}

        ModelTrainer(net::Model{S, I, O}, optimizer::MemoryWrapper{Optimizer.Func}) where {S, I, O} = new{S, I, O}(net, optimizer(net.memsettings))

        function Base.string(x::ModelTrainer)
                layerz = join([string(layer) for layer in x.net.layers], ", ")
                const_count = length(x.net.constants)
                err_func = x.net.error_function
                return "ModelTrainer:\n\tLayers: $layerz\n\tConstant Count: $const_count\n\tError Function: $err_func\n"
        end
end

function Functions.train!(f::ModelTrainer, data::AbstractDataSet; epochs::Int = 1, IsVerbose=true, testset::AbstractDataSet=data)
    t = time()
    err_func = Error.Func2(() -> f.net.error_function(data, f.net))
    test_func = Error.Func2(() -> f.net.error_function(testset, f.net))
    
    if IsVerbose
        println("========MODEL TRAINING STARTED=======")
        println("Initial: Data Error:", err_func(), ". Test Error:", test_func())
        println("Number of Parameters:$(length(f.net.constants))")
    end

    for i in 1:epochs
        res = f.optimizer(f.net.constants, err_func, first(f.net.constant_range), last(f.net.constant_range))
        copy!(f.net.constants, res[1])
        reset(data)
        if IsVerbose
            println("Epoch:$i. Took (", time() - t, ") seconds. Data Error:", res[2], ". Test Error:", test_func())
            t = time()
        end
    end

    if IsVerbose
        println("========MODEL TRAINING ENDED=======")
    end

    (err_func(), test_func())
end

