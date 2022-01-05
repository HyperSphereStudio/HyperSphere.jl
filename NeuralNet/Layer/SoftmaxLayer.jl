#Written By Johnathan Bizzano
export SoftmaxLayer



"
multinomial logistic regression and is often used as the last activation function of a neural network to 
normalize the output of a network to a probability distribution over predicted output classes - Wikipedia"
function SoftmaxLayer(; size::Int)
    return Wrapper(
        function (ST, IT, OT)
            Layer{ST, IT, OT, size, size}(0, nothing, 
                Func{ST, IT, OT}(
                            function (constant_pointer, inputs, outputs)
                                sum::IT = 0
                                for input in inputs
                                    sum += MathConstants.e ^ input
                                end
                                for i in 1:size
                                    outputs[i] = MathConstants.e ^ inputs[i] / sum
                                end
                            end))
        end)
end