#Written By Johnathan Bizzano
module Error
    using ..Functions
    using ..Utils
    using ..Data

    @Fun(Func{OutputType}, OutputType, AbstractDataSet, fun::Any)
    @Fun(Wrapper, Func, InputType::Type, OutputType::Type)

    export Meanabserr, Meansqrerr, Meanerr, None

    diff(fun, entry) = fun(entry.inputs)[1] - entry.outputs[1]

    None() = Wrapper((IT, OT) -> Func{OT}((dataset, fun) -> OT(0)))

    function Meanabserr()
        Wrapper((IT, OT) -> Func{OT}(function (dataset, fun)
                sum::IT = 0
                for item in dataset
                    sum += abs(diff(fun, item))
                end
                OT(sum / length(dataset))
            end))
    end

    function Meansqrerr()
        Wrapper((IT, OT) -> Func{OT}(function (dataset, fun)
                sum::IT = 0
                for item in dataset
                    sum += diff(fun, item) ^ 2
                end
                OT(sqrt(sum / length(dataset)))
            end))
    end

    function Meanerr()
        Wrapper((IT, OT) -> Func{OT}(function (dataset, fun)
                sum::IT = 0
                for item in dataset
                    sum += diff(fun, item)
                end
                OT(sum / length(dataset))
            end))
    end
end

