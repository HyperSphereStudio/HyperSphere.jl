#=
Function:
- Julia version:
- Author: JohnB
- Date: 2021-10-03
=#

using Main.HyperSphere.Functions

export AbstractMathmaticalFunction, inputs, deriv

abstract type AbstractMathmaticalFunction{T} <: HyperSphere.AbstractObject end

functionheader(x::AbstractMathmaticalFunction, var_count::Integer) = "f(x_" * join(1:var_count, ", x_") * ") = "

function (f::AbstractMathmaticalFunction{T})(args::T2...; Data_Type::Type=T) where T where T2
    return f(collect(args), Data_Type = Data_Type)
end


function inputs(x::AbstractMathmaticalFunction{T}) where T
    return
end

function deriv(f::AbstractMathmaticalFunction{T}, point::T; dimension::Integer=1, Data_Type::Type=T, Delta::T=.001) where T

end
