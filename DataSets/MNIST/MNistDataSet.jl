function MNistDataSet(isTrainingData::Bool)
        location = "DataSets/MNIST/" * (isTrainingData ? "train" : "test")
        imageStream  = open("$(location)Images.ubyte", "r")
        labelStream = open("$(location)Labels.ubyte", "r")

        (read(imageStream, Int32) != 2051) && error("Invalid Mnist Image File!")
        (read(labelStream, Int32) != 2049) && error("Invalid Mnist Label File!")
        numImages::Int = read(imageStream, Int32)
        (numImages != read(labelStream, Int32)) && error("Mismatch Image Count!")

        imageStreamImageRows = read(imageStream, Int32)
        imageStreamImageCols = read(imageStream, Int32)
        (imageStreamImageRows != 28 || imageStreamImageCols != 28) && error("Mismatch Image Length!")

        Inputs = Matrix{UInt8}(numImages, 28 * 28)
        Outputs = Array{UInt8}(numImages)

        for i in 1:numImages
            for v in 1:(28 * 28)
                Inputs[i, v] = read(imageStream, UInt8)
            end
            Outputs[i] = read(labelStream, UInt8)
        end
        
        close(imageStream)
        close(labelStream)

        return Data.ReadArrayToDataSet(Inputs, Outputs)
end

