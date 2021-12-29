struct LazyDataSet{T, InputDim, OutputDim} <: AbstractDataSet{T, InputDim, OutputDim}
    reader::LazyDataSetReader
    buffer::MemoryDataSet{T, InputDim, OutputDim}

    function Base.getindex(set::MemoryDataSet{T, I, O}, row, col, is_input::Bool) where {T, I, O}
        
    end

    function Base.setindex(set::MemoryDataSet{T, I, O}, row, col, is_input::Bool, value::T) where {T, I, O}

    end
end
