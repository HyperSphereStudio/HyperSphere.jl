export RandomBatch

"In Memory Data Set"
struct RandomBatch{InputType, OutputType} <: AbstractDataSet{InputType, OutputType}
    data::MemoryDataSet{InputType, OutputType}
    parentSet::AbstractDataSet{InputType, OutputType}

    function RandomBatch(set::AbstractDataSet{I, O}, batch_size::Int) where {I, O}
        newSet = new{I, O}(MemoryDataSet{I, O}(batch_size), set)
        reset(newSet)
        return newSet
    end

    Base.getindex(set::RandomBatch, row) = set.data[row]
    Base.setindex!(set::RandomBatch{I, O}, value::DataEntry{I, O}, row) where {I, O} = set.data[row] = value
    Base.deleteat!(set::RandomBatch, idxes) = deleteat!(set, idxes)
    Base.length(set::RandomBatch)::Int64 = length(set.data)
    
    function Base.reset(set::RandomBatch)
        for i in 1:length(set)
            set[i] = set.parentSet[rand(1:length(set.parentSet))]
        end
    end

end