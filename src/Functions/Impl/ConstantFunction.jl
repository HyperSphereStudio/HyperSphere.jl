export ConstFunction

mutable struct ConstFunction{T} <: AbstractMathFun{T, 0}
    value::T
    force_emit::Bool

    ConstFunction{T}(value; force_emit::Bool = true) where {T} = new{T}(T(value), force_emit)

    (f::ConstFunction{T})(call::MFCall) where {T} = call(f.value)

    isfactor(x, c) = floor(x / c) ≈ (x / c)

    function Functions.string(f::ConstFunction, emitter::FunctionEmitter)
        idx = emitter(f.value, f.force_emit)
        if idx == 0
            return string(f.value)
        end
        return "C[$idx]"
    end

    Base.isequal(f::ConstFunction, f2::ConstFunction) = f.value == f2.value
    
    function Functions.emit(f::ConstFunction{T}, emitter::FunctionEmitter{T}) where {T}
        idx = emitter(f.value, f.force_emit)
        if idx == 0
            return f.value
        end
        return Expr(:ref, :CONSTANTS, idx)
    end
end