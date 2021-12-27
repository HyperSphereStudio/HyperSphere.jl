export AbstractDataSet, MemoryDataSet, LazyDataSet, rowiter, coliter, entryiter, set!, DataEntry

abstract type AbstractDataSet{T, InputDim, OutputDim} <: AbstractArray{T, 1} end
abstract type AbstractDataSetRowIterator{T, InputDim, OutputDim} end
abstract type AbstractDataSetColIterator{T, InputDim, OutputDim} end
abstract type AbstractDataSetEntryIterator{T, InputDim, OutputDim} end

struct DataEntry{T, I, O}
    inputs::NTuple{I, T}
    outputs::NTuple{O, T}
    DataEntry{T, I, O}(inputs::NTuple{I, T}, outputs::NTuple{O, T}) where T where I where O = new{T, I, O}(inputs, outputs)
end

Base.getindex(set::AbstractDataSet, row) = ()
Base.setindex(set::AbstractDataSet, row, value) = ()

rowiter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
coliter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()
entryiter(set::AbstractDataSet; start_range=0, end_range=length(set)) = ()

function Base.print(io::IO, set::AbstractDataSet)
    for item in set
        println(io, "Inputs:", item.inputs, "\tOutputs:", item.outputs)
    end
end

function Base.string(set::AbstractDataSet)
    str = ""
    for item in set
        str *= "Inputs:" * item.inputs * "\tOutputs:" * item.outputs * "\n"
    end
    str
end
