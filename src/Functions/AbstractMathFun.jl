#Written By Johnathan Bizzano

using ..Functions
using ...HyperSphere

export AbstractMathFun, SingleVarMathmaticalFunction, 
MFCollection, MFCall, verify_function, emit, FunctionEmitter, FunctionCall, functionheader, trainer, simplify, is_constant

abstract type AbstractMathFun{T, N} <: AbstractObject end
abstract type AbstractMathmaticalEquation{T, N} <: AbstractMathFun{T, N} end
abstract type SingleVarMathmaticalFunction{T} <: AbstractMathFun{T, 1} end

const MFCollection = Array{AbstractMathFun, 1}

functionheader(x::AbstractMathFun, var_count::Integer) = "f(x_" * join(1:var_count, ", x_") * ") = "

function (f::AbstractMathFun{T, N})(args...; Data_Type=T) where {T, N}
    f(MFCall{T, N}(tuple(args...,), Data_Type))
end

function (f::AbstractMathFun{T, N})(args::NTuple{N, T}; Data_Type=T) where {T, N}
    f(MFCall{T, N}(args, Data_Type))
end

verify_function(f::AbstractMathFun) = ()
simplify(f::AbstractMathFun) = f
simplify(f::AbstractMathFun, emit_constants::Bool) = f
is_constant(f::AbstractMathFun, emit_constants::Bool) = f isa ConstFunction && (emit_constants || f.force_emit)

struct MFCall{T, N}
    args::NTuple{N, T}
    Data_Type::Type
    
    MFCall{T, N}(args::NTuple{N, T}, Data_Type::Type) where {T, N} = new{T, N}(args, Data_Type)

    function (call::MFCall)(arg)
        call.Data_Type(arg)
    end
end

struct FunctionEmitter{T}
    ConstantPool::Vector{T}
    EmitConstants::Bool

    FunctionEmitter{T}(EmitConstants::Bool) where T = new{T}(zeros(T, 0), EmitConstants)

    function (emitter::FunctionEmitter{T})(constant::T, force_emit::Bool) where T
        if emitter.EmitConstants || force_emit
            return 0
        else 
            push!(emitter.ConstantPool, constant)
            return length(emitter.ConstantPool)
        end
    end
end

struct FunctionCall{T, N} <: AbstractMathFun{T, N}
    method::Function
    ConstantPool::Array{T, 1}
    expr::Expr

    FunctionCall{T, N}(constantPool::Array{T, 1}, expr::Expr) where {T, N} = new{T, N}(eval(expr), constantPool)

    FunctionCall{T, N}(method::Function, constantPool::Array{T, 1}, expr::Expr) where {T, N} = new{T, N}(method, constantPool, expr)

    (f::FunctionCall)(args...) = f(collect(args), f.ConstantPool)

    (f::FunctionCall)(args::AbstractArray) = f(args, f.ConstantPool)

    function (f::FunctionCall{T, N})(args::AbstractArray, constants::AbstractArray) where {T, N}
        if length(constants) != 0
            if N != 0
                return f.method(args, constants)
            else
                return f.method(constants)
            end
        else
            if N != 0
                return f.method(args)
            else
                return f.method()
            end
        end
    end

    function Base.string(f::FunctionCall{T, N}) where {T, N}
        str = "Function{$T, $N}:" * string(f.method)
        if length(f.ConstantPool) != 0
            if N != 0
                str *= "(ARGS, CONSTANTS). With Constant Pool:" * string(f.ConstantPool)
            else
                str *= "(CONSTANTS). With Constant Pool:" * string(f.ConstantPool)
            end
        else
            if N != 0
                str *= "(ARGS)"
            else
                str *= "()"
            end
        end
        str
    end
end

function emit(f::AbstractMathFun{T, N}, Name::Symbol; EmitConstants::Bool = true) where {T, N}
    emitter = FunctionEmitter{T}(EmitConstants)
    funArgs = Expr(:call, Name)
    N != 0 && push!(funArgs.args, :ARGS)

    expr = Expr(:function, funArgs)
    EmitConstants || push!(funArgs.args, :CONSTANTS)
    push!(expr.args, Expr(:block, emit(simplify(f), emitter)))
    return FunctionCall{T, N}(eval(expr), emitter.ConstantPool, expr)
end

emit(f::AbstractMathFun{T, N}, emitter::FunctionEmitter{T}) where {T, N} = ()
Functions.string(f::AbstractMathFun{T, N}, emit_constants::Bool) where {T, N} = string(f, FunctionEmitter{T}(emit_constants))



