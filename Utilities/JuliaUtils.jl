export @nullc, eqerror, getbit, setbit, bytesof,
matrixbytesof, objectof, matrixobjectof, issupertype, matrixbitsof, bitsof,
arraybytesof, arrayobjectof, arraybitsof, pass_func, proto, findOrIsMethod

function findOrIsMethod(CheckMod::Module, MethodOrName)
      MethodOrName isa Method && return MethodOrName  
      return isdefined(CheckMod, MethodOrName) ? getproperty(CheckMod, MethodOrName) : nothing
end

function findOrIsMethod(CheckMods::Tuple{Module}, MethodOrName)
      MethodOrName isa Method && return MethodOrName
      for mod in CheckMods
            isdefined(mod, MethodOrName) && return getproperty(mod, MethodOrName)
      end      
      return nothing
end

macro proto(expr)
      Expr(:(=), Expr(:call, expr), Expr(:block))
end 

macro nullc(value, if_null)
      return esc(:($value == nothing ? $if_null : $value))
end

function eqerror(error_message, nums...)
      if length(nums) == 0; return; end
      num = nums[1]
      for number in 2:nums
            if num != number; error(error_message); end
      end
end

@inline function getbit(byte::UInt8, index)::Bool
      return (byte & (UInt8(1) << index)) != 0
end

@inline function setbit(byte::UInt8, index, value::Bool)::UInt8
      return value ? (byte | (UInt8(1) << index)) : (byte & ~(UInt8(1) << index))
end

@inline function bytesof(v::T)::Array{UInt8, 1} where T
      return reinterpret(UInt8, isa(v, AbstractArray) ? v : T[v])
end

function bitsof(v::T)::BitArray where T
      bytes = bytesof(v)
      byte_copy = zeros(UInt8, length(bytes) + (8 - length(bytes) % 8))
      copyto!(byte_copy, bytes)
      bits = BitArray(undef, length(bytes) * 8)
      bits.chunks = reinterpret(UInt64, byte_copy)
      bits
end

function matrixbitsof(v::AbstractArray{T})::BitMatrix where T
      array = BitMatrix(undef, length(v), sizeof(T) * 8)
      for i in 1:length(v)
           array[i, 1:end] = bitsof(v[i])[1:(sizeof(T) * 8)]
      end
      array
end

function matrixbytesof(v::AbstractArray{T})::Matrix{UInt8} where T
      array = zeros(UInt8, length(v), sizeof(T))
      for i in 1:length(v)
           array[i, 1:end] = bytesof(v[i])
      end
      array
end

@inline function objectof(T::Type, bytes::AbstractArray{UInt8})
      obj_arr = reinterpret(T, bytes)
      return T == typeof(obj_arr) ? obj_arr : obj_arr[1]
end

function objectof(T::Type, bits::BitArray)
      bytes = reinterpret(UInt8, bits.chunks)
      object_bytes = zeros(UInt8, sizeof(T))
      copyto!(object_bytes, 1, bytes, 1, length(object_bytes))
      bytes = object_bytes
      objectof(T, bytes)
end


function matrixobjectof(T::Type, v::BitMatrix)
      array = Array{T}(undef, size(v, 1))
      for i in 1:size(v, 1)
            array[i] = objectof(T, v[i, 1:end])
      end
      array
end

function matrixobjectof(T::Type, v::AbstractMatrix{UInt8})
      array = Array{T}(undef, size(v, 1))
      for i in 1:size(v, 1)
            array[i] = objectof(T, v[i, 1:end])
      end
      array
end

function arrayobjectof(T::Type, v::AbstractArray{Array{UInt8, 1}})
      [objectof(T, data) for data in v]
end

function arrayobjectof(T::Type, v::AbstractArray{BitArray})
      [objectof(T, data) for data in v]
end

function arraybytesof(v::AbstractArray{T})::Array{Array{UInt8, 1}, 1} where T
      [bytesof(data) for data in v]
end

function arraybitsof(v::AbstractArray{T})::Array{BitArray, 1} where T
      [bitsof(data) for data in v]
end

function issupertype(type, check)::Bool
 while type != Any
      if type == check; return true; end
      type = supertype(type)
 end
 return false
end