export PowFunction

struct PowFunction{T, N} <: AbstractMathFun{T, N}
    pow::AbstractMathFun
    func::AbstractMathFun

    PowFunction{T, N}(func::AbstractMathFun, pow::T; force_emit=true) where {T, N} = new{T, N}(ConstFunction{T}(pow, force_emit = force_emit), func)
    PowFunction{T, N}(func::AbstractMathFun, pow::AbstractMathFun) where {T, N} = new{T, N}(pow, func)

    (f::PowFunction{T, N})(call::MFCall) where {T, N} = call(f.func(call) ^ f.pow(call))

    function Functions.string(f::PowFunction, emitter::FunctionEmitter)
        return "(" * string(f.func, emitter) * ")^" * string(f.pow, emitter)        
    end

    function Functions.emit(f::PowFunction{T, N}, emitter::FunctionEmitter{T}) where {T, N}
        return Expr(:call, :(^), emit(f.func, emitter), emit(f.pow, emitter))
    end

    function Functions.simplify(f::PowFunction{T, N}, emit_constants::Bool) where {T, N}
        pows = simplify(f.pow, emit_constants)
        funcs = simplify(f.func, emit_constants)
        (is_constant(pows, emit_constants) && is_constant(funcs, emit_constants)) && (return ConstFunction{T}(functs.value ^ pows.value))
        (is_constant(pows, emit_constants) && pows.value == 0) && (return ConstFunction{T}(1))
        (is_constant(pows, emit_constants) && pows.value == 1) && (return funcs)
        return PowFunction{T, N}(funcs, pows)
    end
end