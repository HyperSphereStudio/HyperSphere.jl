#=
Function:
- Julia version:
- Author: JohnB
- Date: 2021-10-03
=#


abstract type AbstractMathmaticalFunction{T <: Real} <: AbstractHSObject end

functionheader(x::AbstractMathmaticalFunction, var_count::Integer) = "f(x_" * join(1:var_count, ", x_") * ") = "

function (f::AbstractMathmaticalFunction{T})(args::T...)::T where T <: Real
    return f(collect(args))
end
