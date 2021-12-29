export AbstractDataSet, MemoryDataSet, LazyDataSet, rowiter, coliter, entryiter, set!, DataEntry, TrainAndTestSplit, randombatch

import ..@Fun

abstract type AbstractDataSet{T, InputDim, OutputDim} <: AbstractArray{T, 1} end

struct DataEntry{T, I, O}
    inputs::NTuple{I, T}
    outputs::NTuple{O, T}
    DataEntry{T, I, O}(inputs::NTuple{I, T}, outputs::NTuple{O, T}) where T where I where O = new{T, I, O}(inputs, outputs)
end

Base.getindex(set::AbstractDataSet, row) = ()
Base.setindex(set::AbstractDataSet, row, value) = ()
Base.size(set::AbstractDataSet) = length(set)

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

@Fun(ElementChooser{T, I, O}, DataEntry{T, I, O}, row::Int)
@Fun(Wrapper, ElementChooser, T::Type, I::Int, O::Int, offset::Int, length::Int)
nonechooser() = Wrapper((T, I, O, offset, length) -> ElementChooser{T, I, O}((row) -> row))

struct SplitDataSet{T, I, O} <: AbstractDataSet{T, I, O}
    parentSet::AbstractDataSet{T, I, O}
    elementChooser::ElementChooser{T, I, O}
    length::Int
    offset::Int

    function SplitDataSet(parentSet::AbstractDataSet{T, I, O}, length::Int; offset::Int = 0, chooser::Wrapper = nonechooser()) where {T, I, O}
        thisWrapper = chooser(T, I, O, offset, length)
        if parentSet isa SplitDataSet
            parentWrapper = parentSet.elementChooser
            return new{T, I, O}(parentSet.parentSet, row -> parentWrapper(thisWrapper(row)), length, offset + parentSet.offset)
        end
        return new{T, I, O}(parentSet, thisWrapper, length, offset)
    end

    Base.length(set::SplitDataSet)::Int = set.length
    Base.getindex(set::SplitDataSet{T, I, O}, row) where {T, I, O} = set.parentSet[set.elementChooser(row + set.offset)]
    Base.setindex!(set::SplitDataSet{T, I, O}, value::DataEntry{T, I, O}, row) where {T, I, O} = set.parentSet[set.elementChooser(row + set.offset)] = value
end

function TrainAndTestSplit(x::AbstractDataSet; trainFrac=.8, sort_randomly=true)
    if sort_randomly
        for i in 1:length(x)
            newi = rand(1:length(x))
            temp = x[i]
            x[i] = x[newi]
            x[newi] = temp
        end
    end
    trainLen = Int(round(length(x) * trainFrac))
    testLen = length(x) - trainLen
    return (SplitDataSet(x, trainLen), SplitDataSet(x, testLen))
end

function randombatch(x::AbstractDataSet, batch_size)
    len = length(x)
    return SplitDataSet(x, batch_size; chooser = Wrapper((T, I, O, offset, length) -> ElementChooser{T, I, O}(row -> rand(1:len))))
end