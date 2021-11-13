import Main.HyperSphere.Functions as Functions
import Main.HyperSphere.Utils as Utils

struct FixedLengthNeuralNet{T <: Real} <: AbstractNeuralNet
    PolynomialMatrix::Array{Functions.MultiVarPolynomial{T}, 2}
    LowError::T
    LowRetrain::T
    Low0::T
    High1::T
    HighRetrain::T
    HighError::T
    FixedLengthIn::Int32
    FixedLengthOut::Int32
    FunctionWidth::Int32

    function FixedLengthNeuralNet{T}(FixedLengthIn, FixedLengthOut, PolynomialWidth,
            EndDegree, NumPolyTerms; StartDegree=0.0, Precision=10, LowError=-6, LowRetrain=-4, Low0=-2, High1=2, HighRetrain=4, HighError=6) where T <: Real
        FixedLengthOut *= 8
        PolynomialMatrix = Array{Functions.MultiVarPolynomial{T}, 2}(undef, FixedLengthOut, PolynomialWidth)
        for row in 1:FixedLengthOut
            for col in 1:PolynomialWidth
                PolynomialMatrix[row, col] = Functions.MultiVarPolynomial{T}(FixedLengthIn + 1, NumPolyTerms, EndDegree, precision = Precision, start_degree = StartDegree)
            end
        end
        return new{T}(PolynomialMatrix, LowError, LowRetrain, Low0, High1, HighRetrain, HighError, FixedLengthIn, FixedLengthOut, PolynomialWidth)
    end

    """ Returns output of Neural Net
    """
    function (f::FixedLengthNeuralNet{T})(args::Array{UInt8, 1}; signal_handler=undef)::Array{UInt8, 1} where T <: Real
        out::Array{UInt8, 1} = Array{UInt8, 1}(undef, size(f.PolynomialMatrix, 1))
        inputs::Array{T} = [T(i) for i in args]
        push!(inputs, 0)
        for row in 1:f.FixedLengthOut
            for col in 1:f.FunctionWidth
                inputs[end] = f.PolynomialMatrix[row, col](inputs)
            end
            if inputs[end] <= f.LowError
                signal_handler.onLowEnd(inputs[end])
            elseif inputs[end] <= f.LowRetrain
                signal_handler.onLowRetrain(inputs[end])
            elseif inputs[end] <= f.Low0
                out[row] = 0
            elseif inputs[end] <= f.High1
                out[row] = 1
            elseif inputs[end] <= f.HighRetrain
                signal_handler.onHighRetrain(inputs[end])
            else
                signal_handler.onHighError(inputs[end])
            end
        end
        out
    end
end


""" Trains neural net
    Make sure to feed array that has one extra space at the end otherwise it will throw error
"""
function train(f::FixedLengthNeuralNet{T}, inputs::Vector{Array{UInt8, 1}}, outputs::Vector{Array{UInt8, 1}}) where T
    if length(inputs) != length(outputs); error("Data Mismatch: Input Len:" * string(length(inputs)) * " Output Len:" * string(length(outputs))); end
    inputMatrix::Matrix{T} = zeros(T, length(inputs), f.FixedLengthIn + 1)
    outputVector::Vector{T} = zeros(T, length(outputs))

    for i in 1:length(inputs)

    end

end

function inactivate_training(f::FixedLengthNeuralNet{T}) where T <: Real
    for row in 1:size(f.PolynomialMatrix, 1)
        for col in 1:size(f.PolynomialMatrix, 2)
            inactivate_training(f.PolynomialMatrix[row, col])
        end
    end
end
