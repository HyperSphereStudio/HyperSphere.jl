export MemoryDataSet

"In Memory Data Set"
struct MemoryDataSet{InputType, OutputType} <: AbstractDataSet{InputType, OutputType}
    data::Vector{DataEntry{InputType, OutputType}}

    function MemoryDataSet(set::AbstractDataSet{I, O}) where {I, O}
        (set isa MemoryDataSet) && return set
        newSet = MemoryDataSet{I, O}(length(set))
        for i in eachindex(set)
            newSet[i] = set[i]
        end
        newSet
    end

    MemoryDataSet{I, O}(length = 0) where {I, O} = new{I, O}(Vector{DataEntry{I, O}}(undef, length))
    Base.append!(set::MemoryDataSet{I, O}, set2::Vector{DataEntry{I, O}}) where {I, O} = append!(set.data, set2)
    Base.push!(set::MemoryDataSet{I, O}, entry::DataEntry{I, O}) where {I, O} = push!(set, entry)
    Base.getindex(set::MemoryDataSet, row) = set.data[row]
    Base.setindex!(set::MemoryDataSet{I, O}, value::DataEntry{I, O}, row) where {I, O} = set.data[row] = value
    Base.deleteat!(set::MemoryDataSet, idxes) = deleteat!(set, idxes)
    Base.length(set::MemoryDataSet)::Int64 = length(set.data)
end