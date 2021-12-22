struct LazyDataSet{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSet{T, InputDim, OutputDim}
    reader::LazyDataSetReader
    buffer::MemoryDataSet{T, InputDim, OutputDim}

    function Base.getindex(set::MemoryDataSet{T, I, O}, row::N, col::N, is_input::Bool) where T where I where O where N <: Integer

    end

    function Base.setindex(set::MemoryDataSet{T, I, O}, row::N, col::N, is_input::Bool, value::T) where T where I where O where N <: Integer

    end
end

struct LazyDataSetRowIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetRowIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::LazyDataSetRowIterator{T, I, O})(value::T) where T where I where O
    end
end

struct LazyDataSetColIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetColIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::LazyDataSetColIterator{T, I, O})(value::T) where T where I where O
    end
end

struct LazyDataSetEntryIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetEntryIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::LazyDataSetEntryIterator{T, I, O})(value::T) where T where I where O
    end
end

#rowiter(set::LazyDataSet; start_range=0, end_range=length(set)) = LazyDataSetRowIterator(set, start_range)
#coliter(set::LazyDataSet; start_range=0, end_range=length(set)) = LazyDataSetColIterator(set, start_range, end_range)
#entryiter(set::LazyDataSet; start_range=0, end_range=length(set)) = LazyDataSetEntryIterator(set, start_range, end_range)
