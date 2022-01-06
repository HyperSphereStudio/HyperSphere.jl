export VarFunction

struct VarFunction{T} <: SingleVarMathmaticalFunction{T}
    var_index::UInt16

    VarFunction{T}(var_index) where {T} = new{T}(UInt16(var_index))

    (f::VarFunction{T})(call::MFCall) where {T} = call(call.args[f.var_index])

    Functions.string(f::VarFunction, emitter::FunctionEmitter) = "x_" * string(f.var_index)
    Base.isequal(f::VarFunction, f2::VarFunction) = f.value == f2.value
    Functions.emit(f::VarFunction{T}, emitter::FunctionEmitter{T}) where {T} = Expr(:ref, :ARGS, Int64(f.var_index))
end