export AbstractDataSet, MatrixDataSet, LazyDataSet, rowiter, coliter, entryiter, set!

abstract type AbstractDataSet{T, InputDim <: Integer, OutputDim <: Integer} end
abstract type AbstractDataSetRowIterator{T, InputDim, OutputDim} end
abstract type AbstractDataSetColIterator{T, InputDim, OutputDim} end
abstract type AbstractDataSetEntryIterator{T, InputDim, OutputDim} end


rowiter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
coliter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
entryiter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
