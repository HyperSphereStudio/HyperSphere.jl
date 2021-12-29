export APtr, increment!, decrement!

mutable struct APtr{T}
    arr::AbstractArray{T}
    ptr::Int
    len::UInt32

    APtr(a::AbstractArray{T}) where T = new{T}(a, 0, length(a))

    Base.length(p::APtr) = p.len
    Base.getindex(p::APtr) = p.arr[p.ptr + 1]
    Base.setindex!(p::APtr{T}, v) where T = p.arr[p.ptr + 1] = v
    Base.getindex(p::APtr, index::Int) = p.arr[index + p.ptr]
    Base.setindex!(p::APtr{T}, v::T, index::Int) where T = p.arr[index + p.ptr] = v
    Base.:+(p::APtr, val) = p.ptr += val
    Base.:-(p::APtr, val) = p.ptr -= val
    Base.iterate(p::APtr) = Base.iterate(p.arr)
    Base.iterate(p::APtr, state) = Base.iterate(p.arr, state)
    Base.getindex(cons::APtr, row_size, row, col) = cons[row_size * (row - 1) + col]
    Base.setindex!(cons::APtr{T}, value, row_size, row, col) where T = cons[row_size * (row - 1) + col] = value

    Base.getindex(cons::APtr, row_size, col_size, row, col, depth) = cons[row_size * (row - 1) + col_size * (col - 1) + depth]
    Base.setindex!(cons::APtr{T}, value, row_size, col_size, row, col, depth) where T = cons[row_size * (row - 1) + col_size * (col - 1) + depth] = value
end

increment!(p::APtr) = incremenet!(p, 1)
decrement!(p::APtr) = decremenet!(p, 1)
increment!(p::APtr, n) = p.ptr += n
decrement!(p::APtr, n) = p.ptr -= n
