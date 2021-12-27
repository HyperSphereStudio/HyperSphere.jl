export MemoryDataSet

"In Memory Data Set"
struct MemoryDataSet{T, InputDim, OutputDim} <: AbstractDataSet{T, InputDim, OutputDim}
    data::Vector{DataEntry{T, InputDim, OutputDim}}

    MemoryDataSet{T, I, O}(length = 0) where {T, I, O} = new{T, I, O}(Vector{DataEntry{T, I, O}}(undef, length))
    Base.iterate(set::MemoryDataSet) = Base.iterate(set.data)
    Base.iterate(set::MemoryDataSet, state) = Base.iterate(set.data, state)
    Base.append!(set::MemoryDataSet{T, I, O}, set2::Vector{DataEntry{T, I, O}}) where {T, I, O} = append!(set.data, set2)
    Base.push!(set::MemoryDataSet{T, I, O}, entry::DataEntry{T, I, O}) where {T, I, O} = push!(set, entry)
    Base.getindex(set::MemoryDataSet{T, I, O}, row) where {T, I, O} = set.data[row]
    Base.setindex!(set::MemoryDataSet{T, I, O}, value::DataEntry{T, I, O}, row) where {T, I, O} = set.data[row] = value
    Base.deleteat!(set::MemoryDataSet{T, I, O}, idxes) where {T, I, O} = deleteat!(set, idxes)
    Base.length(set::MemoryDataSet)::Int64 = length(set.data)
end