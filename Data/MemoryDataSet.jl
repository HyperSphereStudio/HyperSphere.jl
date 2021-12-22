export MemoryDataSet, DataEntry

struct DataEntry{T, I <: Int, O <: Int}
    inputs::NTuple{I, T}
    outputs::NTuple{O, T}
    DataEntry{T, I, O}(inputs::NTuple{I, T}, outputs::NTuple{O, T}) where T where I where O = new{T, I, O}(inputs, outputs)
end

"In Memory Data Set"
struct MemoryDataSet{T, InputDim <: Int, OutputDim <: Int} <: AbstractDataSet{T, InputDim, OutputDim}
    data::Vector{DataEntry{T, InputDim, OutputDim}}

    function MemoryDataSet{T, I, O}(length = 0) where T where I <: Int where O <: Int
        return new{T, I, O}(Vector{DataEntry{T, I, O}}(undef, length))
    end

    function Base.append!(set::MemoryDataSet{T, I, O}, set2::Vector{DataEntry{T, I, O}}) where T where I where O
        append!(set.data, set2)
    end

    function Base.push!(set::MemoryDataSet{T, I, O}, entry::DataEntry{T, I, O}) where T where I where O
        push!(set, entry)
    end

    function Base.getindex(set::MemoryDataSet{T, I, O}, row)::T where T where I where O
        return set.data[row]
    end

    function Base.setindex(set::MemoryDataSet{T, I, O}, row, value::DataEntry{T, I, O}) where T where I where O
        set.data[row] = value
    end

    function Base.deleteat!(set::MemoryDataSet{T, I, O}, idxes) where T where I where O
        deleteat!(set, idxes)
    end

    Base.length(set::MemoryDataSet)::Int64 = length(set.data)
end


struct MatrixDataSetRowIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetRowIterator{T, InputDim, OutputDim}
    "Set the value at the specific index"
    function (ritr::MatrixDataSetRowIterator{T, I, O})(value::T) where T where I where O
    end
end

struct MatrixDataSetColIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetColIterator{T, InputDim, OutputDim}
    "Set the value at the specific index"
    function (ritr::MatrixDataSetColIterator{T, I, O})(value::T) where T where I where O
    end
end

struct MatrixDataSetEntryIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetEntryIterator{T, InputDim, OutputDim}
    "Set the value at the specific index"
    function (ritr::MatrixDataSetEntryIterator{T, I, O})(value::T) where T where I where O
    end
end

rowiter(set::MemoryDataSet; start_range=0, end_range=length(set)) = MatrixDataSetRowIterator(set, start_range)
coliter(set::MemoryDataSet; start_range=0, end_range=length(set)) = MatrixDataSetColIterator(set, start_range, end_range)
entryiter(set::MemoryDataSet; start_range=0, end_range=length(set)) = MatrixDataSetEntryIterator(set, start_range, end_range)
