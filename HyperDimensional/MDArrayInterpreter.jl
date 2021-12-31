#Written By Johnathan Bizzano
export MDArrayInterpreter

"Interpret Array{1} as a Array{D}"
struct MDArrayInterpreter{D, OneLessD}
    products::NTuple{OneLessD, Int}
    dimensions::NTuple{D, Int}
    size::Int
    
    function MDArrayInterpreter(dimensions::NTuple{D, Int}) where D
        prod = 1
        products = zeros(Int, D - 1)
        count = 1
        for i in D:2
            prod *= dimensions[i]
            products[count] = prod
            count += 1            
        end
        new{D, D - 1}((products...,), dimensions, ∏(dimensions))
    end

    function Base.getindex(array::AbstractArray, interpreter::MDArrayInterpreter{D}, idxs::AbstractArray{Int}) where D
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)]
    end

    function Base.setindex!(array::AbstractArray{T}, value::T, interpreter::MDArrayInterpreter{D}, idxs::AbstractArray{Int}) where {D, T}
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)] = value
    end 

    function Base.getindex(array::APtr, interpreter::MDArrayInterpreter{D}, idxs::AbstractArray{Int}) where D
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)]
    end

    function Base.setindex!(array::APtr, value::T, interpreter::MDArrayInterpreter{D}, idxs::AbstractArray{Int}) where {D, T}
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)] = value
    end 

    function getscalarindex(interpreter::MDArrayInterpreter{D}, idxs::AbstractArray{Int}) where D
        sum = 0
        for i in 1:(D - 1)
            sum += interpreter.products[i] * (idxs[i] - 1)
        end
        return sum + idxs[end]
    end

    

    function Base.getindex(array::AbstractArray, interpreter::MDArrayInterpreter{D}, idxs::Int...) where D
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)]
    end

    function Base.setindex!(array::AbstractArray{T}, value::T, interpreter::MDArrayInterpreter{D}, idxs::Int...) where {D, T}
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)] = value
    end 

    function Base.getindex(array::APtr, interpreter::MDArrayInterpreter{D}, idxs::Int...) where D
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)]
    end

    function Base.setindex!(array::APtr, value::T, interpreter::MDArrayInterpreter{D}, idxs::Int...) where {D, T}
        (D == 0) && return
        array[getscalarindex(interpreter, idxs)] = value
    end 

    function getscalarindex(interpreter::MDArrayInterpreter{D}, idxs::NTuple{D, Int}) where D
        sum = 0
        for i in 1:(D - 1)
            sum += interpreter.products[i] * (idxs[i] - 1)
        end
        return sum + idxs[end]
    end

    Base.length(interpreter::MDArrayInterpreter) = interpreter.size

    function Base.checkbounds(interpreter::MDArrayInterpreter{D}, idxs::Int...)::Bool where D
        for i in 1:length(idxs)
            (idxs[i] < 1 || interpreter.dimensions[i] < idxs[i]) && return false
        end
        return true
    end

    function Base.checkbounds(interpreter::MDArrayInterpreter{D}, idxs::AbstractArray{Int})::Bool where D
        for i in 1:length(idxs)
            (idxs[i] < 1 || interpreter.dimensions[i] < idxs[i]) && return false
        end
        return true
    end
end


