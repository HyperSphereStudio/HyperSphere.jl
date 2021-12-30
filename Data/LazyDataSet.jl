export Reader


@Fun(Reader{T, InputDim, OutputDim}, DataEntry{T, InputDim, OutputDim}, row::Int)

struct LazyDataSet{T, InputDim, OutputDim} <: AbstractDataSet{T, InputDim, OutputDim}
    reader::Reader{T, InputDim, OutputDim}
    data::Array{DataEntry{T, InputDim, OutputDim}}
    loaded_rows::Array{Int}
    length::Int

    function LazyDataSet(reader::Reader{T, I, O}, buffer_size::Int, length::Int) where {T, I, O}
        set = new{T, I, O}(reader, Array{DataEntry{T, I, O}}(undef, buffer_size), zeros(Int, buffer_size), length)
        for i in buffer_size:-1:1
            set[i]
        end        
        set
    end

    function findRow(set, row)
        for i in 1:length(set.loaded_rows)
            set.data[i] == row && return i         
        end
        return 0
    end

    function shiftRight(array::AbstractArray{T}) where T
        for i in 2:(length(array) - 1)
            temp::T = array[i]
            array[i] = array[i - 1]
            array[i + 1] = temp
        end
    end

    function Base.getindex(set::LazyDataSet, row::Int)
        rowIdx = findRow(set, row)
        if rowIdx == 0
            shiftRight(set.loaded_rows)
            set.loaded_rows[1] = row
            shiftRight(set.data)
            set.data[1] = set.reader(row)
            rowIdx = 1
        end
        return set.data[set.loaded_rows[rowIdx]]
    end

    Base.length(set::LazyDataSet) = set.length
end
