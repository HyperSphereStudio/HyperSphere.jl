export ErrorFunction, meanabserr, meansqrerr, meanerr

const ErrorFunction{T} = Fun{Number, Tuple{Iterable{T}, Type}}

function meanabserr(DataType::Type)
    ErrorFunction{DataType}(
        function (args)
            sum::Float64 = 0
            for item in args[1]
                sum += abs(item)
            end
            args[2](sum / length(args[1]))
        end)
end

function meansqrerr(DataType::Type)
    ErrorFunction{DataType}(
        function (args)
            sum::Float64 = 0
            for item in args[1]
                sum += item ^ 2
            end
            args[2](sqrt(sum / length(args[1])))
        end)
end

function meanerr(DataType::Type)
    ErrorFunction{DataType}(
        function (args)
            sum::Float64 = 0
            for item in args[1]
                sum += item
            end
            args[2](sum / length(args[1]))
        end)
end
