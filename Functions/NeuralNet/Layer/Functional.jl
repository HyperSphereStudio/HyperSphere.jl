module Functional
    using ..Utils

    @Fun(Func{T}, T, inputs::Array{T, 1})
    @DocFun(Func{T}, "Function that goes from Rn -> R1")


    function summation(T::Type)
        Func{T}(
            function (inputs)
                sum::Float64 = 0
                for arg in inputs
                    sum += arg
                end
                T(sum)
            end)
    end

    function product(T::Type)
        Func{T}(
            function (inputs)
                product::Float64 = 0
                for arg in inputs
                    product *= arg
                end
                T(product)
            end)
    end
end


