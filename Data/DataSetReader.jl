#Written By Johnathan Bizzano
export ReadArrayToDataSet

function ReadArrayToDataSet(inputs::AbstractArray{I}, outputs::AbstractArray{O}) where {I, O}
    data = MemoryDataSet{I, O}(size(inputs, 1))
    inputs = [row for row in eachrow(inputs)]
    outputs = [row for row in eachrow(outputs)]
    for i in eachindex(inputs)
        data[i] = DataEntry{I, O}(Array(inputs[i][1:end]), Array(outputs[i][1:end]))
    end
    return data
end