module BuiltInFunctions

    using ..Functions
    using ..HyperDimensional

    include("ConstantFunction.jl")
    include("VarFunction.jl")
    include("PowFunction.jl")
    include("ProductFunction.jl")
    include("SumFunction.jl")


    function _test()
        sum = ProductFunction{Float64, 2}(
                AbstractMathFun[
                    ConstFunction{Float64}(2.0), VarFunction{Float64}(1),
                    VarFunction{Float64}(2)])
        emit(sum, :TestSum)
    end

    function test()
        @assert (_test()(2.0, 3.0) == 12.0) "Incorrect Function Output!"
    end
end

