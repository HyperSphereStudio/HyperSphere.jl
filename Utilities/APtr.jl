export APtr

struct APtr{T}
    p::Ptr{T}
    len::UInt32

    function APtr(p::Ptr{T}, len) where T
        new{T}(p, len)
    end

    function APtr(v::Vector{T}) where T
         new{T}(pointer(v), length(v))
    end

    function APtr(a::Array{T, 1}) where T
        new{T}(pointer(a), length(a))
    end

    Base.length(p::APtr) = len

    function Base.getindex(p::APtr, index::UInt32)
        return p.p[index]
    end

    function Base.setindex(p::APtr, v, index::UInt32)
        p.p[index] = v
    end

    Base.:+(p::APtr, val) = APtr(p.p + val, length(p) - val)
    Base.:-(p::APtr, val) = APtr(p.p - val, length(p) + val)
end
