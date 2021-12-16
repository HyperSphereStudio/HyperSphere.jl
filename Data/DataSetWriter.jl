using Classes

export AbstractDataSetWriter, MatrixDataSetWriter, CSVDataSetWriter, LazyDataSetWriter

@class DataSetWriter begin

end

@class MatrixDataSetWriter <: DataSetWriter begin

end

@class CSVDataSetWriter <: DataSetWriter begin

end

@class LazyDataSetWriter <: DataSetWriter begin

end
