using Classes

export AbstractDataSetReader, MatrixDataSetReader, CSVDataSetReader, LazyDataSetReader

@class DataSetReader begin
    
end

@class MatrixDataSetReader <: DataSetReader begin

end

@class CSVDataSetReader <: DataSetReader begin

end

@class LazyDataSetReader <: DataSetReader begin

end
