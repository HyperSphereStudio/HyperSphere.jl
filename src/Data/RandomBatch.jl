export RandomBatch

"In Memory Data Set"
struct RandomBatch{InputType, OutputType, Device} <: AbstractDataSet{InputType, OutputType, Device}
    data::MemoryDataSet{InputType, OutputType, Device}
    parentSet::AbstractDataSet{InputType, OutputType, Device}

    function RandomBatch(set::AbstractDataSet{I, O, D}, batch_size::Int) where {I, O, D}
        newSet = new{I, O, D}(MemoryDataSet{I, O, D}(batch_size), set)
        reset(newSet)
        return newSet
    end

    Base.getindex(set::RandomBatch, row) = set.data[row]
    Base.setindex!(set::RandomBatch{I, O, D}, value::DataEntry{I, O, D}, row) where {I, O, D} = set.data[row] = value
    Base.deleteat!(set::RandomBatch, idxes) = deleteat!(set, idxes)
    Base.length(set::RandomBatch)::Int64 = length(set.data)
    
    function Base.reset(set::RandomBatch)
        for i in 1:length(set)
            set[i] = set.parentSet[rand(1:length(set.parentSet))]
        end
    end

end