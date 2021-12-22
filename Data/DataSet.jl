export AbstractDataSet, MemoryDataSet, LazyDataSet, rowiter, coliter, entryiter, set!

abstract type AbstractDataSet{T, InputDim <: Int, OutputDim <: Int} end
abstract type AbstractDataSetRowIterator{T, InputDim, OutputDim} end
abstract type AbstractDataSetColIterator{T, InputDim, OutputDim} end
abstract type AbstractDataSetEntryIterator{T, InputDim, OutputDim} end


Base.getindex(set::AbstractDataSet, row) = ()
Base.setindex(set::AbstractDataSet, row, value) = ()

rowiter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
coliter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
entryiter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
