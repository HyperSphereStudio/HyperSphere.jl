include("../HyperSphere.jl")
import .HyperSphere

interval_width = 2.0
low_term = -2 * interval_width
low = -interval_width
high = interval_width
high_term = 2 * interval_width

middle_low_term = low_term - interval_width / 2
middle_low = low - interval_width / 2
middle_high = high - interval_width / 2
middle_high_term = high_term - interval_width / 2
"""
println("HI:", @allocated net = HyperSphere.LinearFixedLengthNeuralNet{Float32}(5, 1,
    function (value, output_vector, index)
        if value <= low_term
             push!(output_vector, false)
             return true
        elseif value <= low
             push!(output_vector, false)
        elseif value <= high
             push!(output_vector, true)
        else
             push!(output_vector, true)
             return true
        end
        return false
    end,
    function (value, row, col, is_terminating)
        return is_terminating ? (value == 1 ? middle_high_term : middle_low_term) : (value == 1 ? middle_high : middle_low)
    end,
    HyperSphere.basic_poly_initializer(Float32, 3, 2.0)))
"""


#net = HyperSphere.reals_to_real(1, 1, 3, 2.0)

inputMat = zeros(Float32, 10, 1)
for i in 1:size(inputMat, 1)
    inputMat[i, 1] = i
end
#HyperSphere.train(net, inputMat, Float32[(i + 1) for i in 1:10])
