#Written By Johnathan Bizzano
export ReadArrayToDataSet

function ReadArrayToDataSet(inputs::AbstractArray{T}, outputs::AbstractArray{T}) where T
    if length(size(inputs)) == 2
        input_len = size(inputs, 2)
        output_len = size(outputs, 2)
        data = MemoryDataSet{T, input_len, output_len}(size(inputs, 1))
        for i in 1:size(inputs, 1)
            data[i] = DataEntry{T, input_len, output_len}(tuple(inputs[i, 1:end]...,), tuple(outputs[i, 1:end]...,))
        end
        return data
    elseif length(size(inputs)) == 1
        data = MemoryDataSet{T, 1, 1}(size(inputs, 1))
        for i in 1:size(inputs, 1)
            data[i] = DataEntry{T, 1, 1}(tuple(inputs[i]), tuple(outputs[i]))
        end
        return data
    end
    error("Incorrect Dimension Count:", length(size(inputs)))
end