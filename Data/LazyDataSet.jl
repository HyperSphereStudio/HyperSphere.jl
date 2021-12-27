struct LazyDataSet{T, InputDim, OutputDim} <: AbstractDataSet{T, InputDim, OutputDim}
    reader::LazyDataSetReader
    buffer::MemoryDataSet{T, InputDim, OutputDim}

    function Base.getindex(set::MemoryDataSet{T, I, O}, row, col, is_input::Bool) where {T, I, O}

    end

    function Base.setindex(set::MemoryDataSet{T, I, O}, row, col, is_input::Bool, value::T) where {T, I, O}

    end
end

struct LazyDataSetRowIterator{T, InputDim, OutputDim} <: AbstractDataSetRowIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::LazyDataSetRowIterator{T, I, O})(value::T) where {T, I, O}
    end
end

struct LazyDataSetColIterator{T, InputDim, OutputDim} <: AbstractDataSetColIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::LazyDataSetColIterator{T, I, O})(value::T) where {T, I, O}
    end
end

struct LazyDataSetEntryIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetEntryIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::LazyDataSetEntryIterator{T, I, O})(value::T) where {T, I, O}
    end
end

#rowiter(set::LazyDataSet; start_range=0, end_range=length(set)) = LazyDataSetRowIterator(set, start_range)
#coliter(set::LazyDataSet; start_range=0, end_range=length(set)) = LazyDataSetColIterator(set, start_range, end_range)
#entryiter(set::LazyDataSet; start_range=0, end_range=length(set)) = LazyDataSetEntryIterator(set, start_range, end_range)
