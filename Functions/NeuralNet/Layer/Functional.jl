module Functional
    using ..Utils

    @Fun(Func{InputType}, InputType, inputs::Array{InputType, 1})
    @Fun(Wrapper, Func, InputType::Type)

    export ∑, None, ∏

    None() = Wrapper((IT) -> Func{IT}(inputs -> IT(inputs[1])))

    function ∑()
        Wrapper((IT) -> Func{IT}(
            function (inputs)
                sum::IT = 0
                for arg in inputs
                    sum += arg
                end
                IT(sum)
            end))
    end

    function ∏()
        Wrapper((IT) -> Func{IT}(
            function (inputs)
                product::IT = 0
                for arg in inputs
                    product *= arg
                end
                IT(product)
            end))
    end
end


