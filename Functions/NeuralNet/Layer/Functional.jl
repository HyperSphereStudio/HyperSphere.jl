"Written By Johnathan Bizzano"
module Functional
    using ..Utils

    @Fun(Func{InputType}, InputType, inputs::APtr{InputType}, idx::Int)
    @Fun(Wrapper, Func, InputType::Type)

    export ∑, None, ∏, argmaxidx, argminidx, μ, argmax, argmin

    None() = Wrapper((IT) -> Func{IT}((inputs, idx) -> IT(inputs[idx])))


    function argmax()
        Wrapper((IT) -> Func{IT}(
            function (inputs, idx)
                maxVal::IT = -Inf
                for arg in inputs
                    maxVal = max(maxVal, arg)
                end
                IT(maxVal)
            end))
    end

    function argmin()
        Wrapper((IT) -> Func{IT}(
            function (inputs, idx)
                minVal::IT = -Inf
                for arg in inputs
                    minVal = min(minVal, arg)
                end
                IT(minVal)
            end))
    end

    function μ()
        Wrapper((IT) -> Func{IT}(
            function (inputs, idx)
                sum::It = 0
                for arg in inputs
                    sum += arg
                end
                IT(sum / length(inputs))
            end))
    end    

    function argmaxidx()
        Wrapper((IT) -> Func{IT}(
            function (inputs, idx)
                maxVal::IT = -Inf
                maxIdx = 1
                idx = 1
                for arg in inputs
                    if maxVal < arg
                        maxVal = arg
                        maxIdx = idx
                    end
                    idx += 1
                end
                IT(maxVal)
            end))
    end

    function argminidx()
        Wrapper((IT) -> Func{IT}(
            function (inputs, idx)
                minVal::IT = Inf
                minIdx = 1
                idx = 1
                for arg in inputs
                    if minVal > arg
                        minVal = arg
                        minIdx = idx
                    end
                    idx += 1
                end
                IT(minVal)
            end))
    end

    function ∑()
        Wrapper((IT) -> Func{IT}(
            function (inputs, idx)
                sum::IT = 0
                for arg in inputs
                    sum += arg
                end
                IT(sum)
            end))
    end

    function ∏()
        Wrapper((IT) -> Func{IT}(
            function (inputs, idx)
                product::IT = 0
                for arg in inputs
                    product *= arg
                end
                IT(product)
            end))
    end
end


