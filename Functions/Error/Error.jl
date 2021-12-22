export ErrorFunction, meanabserr, meansqrerr, meanerr

const ErrorFunction{Iterator, T <: Number} = Fun{T, Tuple{Iterator}}

function meanabserr(Iterator::Type; DataType::Type = Float64)
    ErrorFunction{Iterator, DataType}(
        function (iter)
            sum::T = 0
            for item in iter
                sum += abs(item)
            end
            sum / length(net)
        end)
end

function meansqrerr(Iterator::Type; DataType::Type = Float64)
    ErrorFunction{Iterator, DataType}(
        function (iter)
            sum::T = 0
            for item in iter
                sum += item ^ 2
            end
            sqrt(sum / length(net))
        end)
end

function meanerr(Iterator::Type; DataType::Type = Float64)
    ErrorFunction{Iterator, DataType}(
        function (iter)
            sum::T = 0
            for item in iter
                sum += item
            end
            sum / length(net)
        end)
end
