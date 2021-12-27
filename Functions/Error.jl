module Error
    using ..Functions
    using ..Utils

    @Fun(Func{T}, Number, Iterable{T}, DataType::Type)

    export meanabserr, meansqrerr, meanerr

    function meanabserr(DataType::Type)
        Func{DataType}(
            function (iter, T)
                sum::Float64 = 0
                for item in iter
                    sum += abs(item)
                end
                T(sum / length(iter))
            end)
    end

    function meansqrerr(DataType::Type)
        Func{DataType}(
            function (iter, T)
                sum::Float64 = 0
                for item in iter
                    sum += item ^ 2
                end
                T(sqrt(sum / length(iter)))
            end)
    end

    function meanerr(DataType::Type)
        Func{DataType}(
            function (iter, T)
                sum::Float64 = 0
                for item in iter
                    sum += item
                end
                T(sum / length(iter))
            end)
    end
end

