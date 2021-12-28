export APtr, increment!, decrement!

mutable struct APtr{T}
    arr::AbstractArray{T}
    ptr::Int
    len::UInt32

    APtr(a::AbstractArray{T}) where T = new{T}(a, 0, length(a))

    Base.length(p::APtr) = p.len
    Base.getindex(p::APtr) = p.arr[p.ptr + 1]
    Base.setindex!(p::APtr, v) = p.arr[p.ptr + 1] = v
    Base.getindex(p::APtr, index::Int) = p.arr[index + p.ptr]
    Base.setindex!(p::APtr, v, index::Int) = p.arr[index + p.ptr] = v
    Base.:+(p::APtr, val) = p.ptr += val
    Base.:-(p::APtr, val) = p.ptr -= val
end

increment!(p::APtr) = incremenet!(p, 1)
decrement!(p::APtr) = decremenet!(p, 1)
increment!(p::APtr, n) = p.ptr += n
decrement!(p::APtr, n) = p.ptr -= n
