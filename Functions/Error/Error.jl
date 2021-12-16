export meanabserr, meansqrerr, meanerr

using Main.Data

abstract type ErrorFunction{T <: Type} <: Fun{T, Tuple{TrainableNeuralNet}} end


function meanabserr(T::Type)
    ErrorFunction{T}(
    function (net)
        sum = 0
        for i in 1:length(net)
            
        end
        sum / length(net)
    end)
end

function meansqrerr(net::TrainableNeuralNet)
    sum = 0
    for i in 1:length(x_values)
        sum += (func(x_values[i]) - y_values[i]) ^ 2
    end
    sqrt(sum) / length(x_values)
end

function meanerr(realDataSet::DataSet, func::AbstractMathmaticalFunction)
    sum = 0
    for i in 1:length(x_values)
        sum += func(x_values[i]) - y_values[i]
    end
    sum / length(x_values)
end
