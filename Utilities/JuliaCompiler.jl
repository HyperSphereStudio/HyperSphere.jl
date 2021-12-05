const compiler_version = 0
const Symbol_Table = [:block, :call, :quote, :begin, :invoke, :struct, :module, :end, :invoke]
const Type_Table = [String, UInt8, UInt16, UInt32, UInt64, Int8, Int16, Int32, Int64, Float16, Float32, Float64, Char, Bool, Symbol, Expr, LineNumberNode, Vector{Any}]

TableIndex = UInt8
LengthIndex = UInt16

struct InvalidOperationException <: Exception
        var::String
end

macro compile(expr)
    bytes = UInt8[compiler_version]
    _serialize(bytes, expr)
    println("Decompile:", decompile(bytes))
    bytes
end

function decompile(bytes)
    if bytes[1] != compiler_version; throw(InvalidOperationException("Compiler Version Incorrect!")); end
    _deserialize(bytes, 2)
end

function _deserialize(bytes, position)
    type = from_table_index(Type_Table, bytes[position])
    if type == nothing
        throw(InvalidOperationException("Unable to deserialize due to missing type"))
    end

    position += 1
    if type == Symbol
        symtype = from_table_index(Symbol_Table, bytes[position])
        position += 1
        if symtype == nothing
            _deserialize(bytes)
        else
            return symtype
        end
    elseif type == String
        len_idx = sizeof(LengthIndex)
        str_len = reinterpret(LengthIndex, [bytes[position + b] for b in 1:len_idx])
        str_buffer = zeros(UInt8, str_len)
        position += len_idx
        for i in 1:str_len
            str_buffer = bytes[position]
            position += 1
        end
        String(str_buffer)
    elseif isbitstype(type)
        buffer = zeros(UInt8, sizeof(type))
        for i in 1:sizeof(type)
            buffer = bytes[position]
            position += 1
        end
        reinterpret(type, buffer)
    elseif type == Any[]
        len_idx = sizeof(LengthIndex)
        len = reinterpret(LengthIndex, [bytes[b] for b in 1:len_idx])
        position += len_idx
        arr = Vector{Any}(undef, len)
        for i in 1:len
            arr[i] = _deserialize(bytes, position)
        end
    else
        inst = type()
        for field_index in 1:fieldcount(typeof(obj))
            setfield!(inst, field_index, _deserialize(bytes, position))
        end
        inst
    end
end

function _serialize(bytes, obj)
    type_index = table_index(Type_Table, typeof(obj))
    if type_index == 0
        throw(InvalidOperationException("Unable to serialize $obj of type:" * string(typeof(obj))))
    end
    append!(bytes, type_index)
    if typeof(obj) == Symbol
        index = table_index(Symbol_Table, obj)
        append!(bytes, index)
        if index == 0
            _serialize(bytes, string(obj))
        end
    elseif typeof(obj) == String
        str_bytes = reinterpret(UInt8, transcode(UInt16, obj))
        _serialize(bytes, LengthIndex(length(str_bytes)))
        append!(bytes, str_bytes)
    elseif isbits(obj)
        append!(bytes, reinterpret(UInt8, [obj]))
    elseif typeof(obj) == Any[]
        _serialize(bytes, LengthIndex(length(str_bytes)))
        for item in obj
            _serialize(bytes, item)
        end
    else
        for field_index in 1:fieldcount(typeof(obj))
            _serialize(bytes, getfield(obj, field_index))
        end
    end
end

function table_index(Table, sym)::TableIndex
    for i in 1:length(Table)
        if Table[i] == sym
            return TableIndex(i)
        end
    end
    return TableIndex(0)
end

function from_table_index(Table, index::TableIndex)
    return index == 0 ? nothing : Table[index]
end

println(@compile(begin
    struct g
    end
end))
