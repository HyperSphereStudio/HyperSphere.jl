"""Data Set In Memory """
struct MatrixDataSet{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSet{T, InputDim, OutputDim}
    inputs::Matrix{T}
    outputs::Matrix{T}
    length::Int64

    function MatrixDataSet{I, O}(inputs::Matrix{T}, outputs::Matrix{T}, length::Int64) where T where I <: Integer where O <: Integer
        return new{T, I, O}(inputs, outputs, length)
    end

    function MatrixDataSet{I, O}(T::Type) where T where I <: Integer where O <: Integer
        return new{T, I, O}(zeros(T, InputDim), zeros(T, OutputDim), 0)
    end

    function check_size(new_size::Integer)
        
        length = new_size
    end

    function Base.append!(set::MatrixDataSet{T, I, O}, inputs::Vector{Array{T, 1}}, ) where T where I where O where C <: Integer
    end

    function Base.push!(set::MatrixDataSet{T, I, O}, input::Array{T, 1}, output::Array{T, 1}) where T where I where O where C <: Integer
        check_size(set.length + 1)
        inputs[set.length, 1:end] = input
        outputs[set.length, 1:end] = output
    end

    function Base.getindex(set::MatrixDataSet{T, I, O}, row::N, col::N, is_input::Bool)::T where T where I where O where N <: Integer
        return (is_input ? set.inputs : set.outputs)[row, col]
    end

    function Base.setindex(set::MatrixDataSet{T, I, O}, row::N, col::N, is_input::Bool, value::T) where T where I where O where N <: Integer
        (is_input ? set.inputs : set.outputs)[row, col] = value
    end

    function Base.deleteat!(set::MatrixDataSet{T, I, O}, idx::N) where T where I where O where N <: Integer

    end

    Base.length(set::MatrixDataSet)::Int64 = set.length
end


struct MatrixDataSetRowIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetRowIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::MatrixDataSetRowIterator{T, I, O})(value::T) where T where I where O
    end
end

struct MatrixDataSetColIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetColIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::MatrixDataSetColIterator{T, I, O})(value::T) where T where I where O
    end
end

struct MatrixDataSetEntryIterator{T, InputDim <: Integer, OutputDim <: Integer} <: AbstractDataSetEntryIterator{T, InputDim, OutputDim}
    """Set the value at the specific index"""
    function (ritr::MatrixDataSetEntryIterator{T, I, O})(value::T) where T where I where O
    end
end

rowiter(set::MatrixDataSet; start_range=0, end_range=length(set)) = MatrixDataSetRowIterator(set, start_range)
coliter(set::MatrixDataSet; start_range=0, end_range=length(set)) = MatrixDataSetColIterator(set, start_range, end_range)
entryiter(set::MatrixDataSet; start_range=0, end_range=length(set)) = MatrixDataSetEntryIterator(set, start_range, end_range)
