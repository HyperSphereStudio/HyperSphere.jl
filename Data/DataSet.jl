export AbstractDataSet, MemoryDataSet, LazyDataSet, rowiter, coliter, entryiter, set!, DataEntry, TrainAndTestSplit, randombatch

import ..@Fun

abstract type AbstractDataSet{InputType, OutputType} <: AbstractArray{T} end

struct DataEntry{InputType, OutputType}
    inputs::Array{InputType}
    outputs::Array{OutputType}
    DataEntry(inputs::Array{I}, outputs::Array{O}) where {I, O, M} = new{I, O}(inputs, outputs)
end


Base.size(set::AbstractDataSet) = length(set)
Base.eltype(::Type{A}) where {I, O, A <: AbstractDataSet{I, O}} = DataEntry{I, O}
Base.iterate(set::AbstractDataSet, state) = state <= length(set) ? (set[state], state + 1) : nothing
Base.iterate(set::AbstractDataSet) = Base.iterate(set, 1)
Base.reset(set::AbstractDataSet) = ()
Base.eachindex(set::AbstractDataSet) = 1:length(set)

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

function TrainAndTestSplit(x::AbstractDataSet; trainFrac=.8)
    trainLen = Int(round(length(x) * trainFrac))
    return (view(x, 1:trainLen) , view(x, trainLen:length(x)))
end