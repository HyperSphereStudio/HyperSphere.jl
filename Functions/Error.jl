#Written By Johnathan Bizzano
module Error
    using ..Functions
    using ..Utils
    using ..Data

    @Fun(Func, Float64, AbstractDataSet, fun::Any)
    @Fun(WrappedFunc, Float64)

    export Meanabserr, Meansqrerr, Meanerr, None

    diff(fun, entry) = fun(entry.inputs)[1] - entry.outputs[1]

    None() = Func((dataset, fun) -> 0.0)

    function Meanabserr()
        return Func(function (dataset, fun)
                sum = 0.0
                for item in dataset
                    sum += abs(diff(fun, item))
                end
                sum / length(dataset)
            end)
    end

    function Meansqrerr()
        return Func(function (dataset, fun)
                sum = 0.0
                for item in dataset
                    sum += diff(fun, item) ^ 2
                end
                sqrt(sum / length(dataset))
            end)
    end

    function Meanerr()
        return Func(function (dataset, fun)
                sum = 0.0
                for item in dataset
                    sum += diff(fun, item)
                end
                sum / length(dataset)
            end)
    end
end

