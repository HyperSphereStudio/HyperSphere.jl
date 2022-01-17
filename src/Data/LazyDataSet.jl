export Reader


@Fun(Reader{InputDim, OutputDim}, DataEntry{InputDim, OutputDim}, row::Int)
#Written By Johnathan Bizzano
struct LazyDataSet{InputType, OutputType} <: AbstractDataSet{InputType, OutputType}
    reader::Reader{InputType, OutputType}
    length::Int

    LazyDataSet(reader::Reader{I, O}, length::Int) where {I, O} = new{I, O}(reader, length)

    Base.getindex(set::LazyDataSet, row::Int) = set.reader(row)

    Base.length(set::LazyDataSet) = set.length
end
