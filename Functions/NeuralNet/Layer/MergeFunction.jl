"Function that goes from Rn -> R1"
const MergeFunction{T} = Fun{T, Tuple{Array{T, 1}}}

function addition_merge(T::Type=Float64)
    MergeFunction{T}(
        function (inputs)
            sum = 0
            for arg in args
                sum += arg
            end
            sum
        end)
end

function multiplication_merge(T::Type=Float64)
    MergeFunction{T}(
        function (inputs)
            product = 0
            for arg in args
                product *= arg
            end
            product
        end)
end
