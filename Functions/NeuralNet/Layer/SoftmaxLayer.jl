export SoftmaxLayer



"
multinomial logistic regression and is often used as the last activation function of a neural network to 
normalize the output of a network to a probability distribution over predicted output classes - Wikipedia"
function SoftmaxLayer(; input_size::Int, output_size::Int, const_initializer)
    return Wrapper(
        function (ST, IT, OT)
            Layer{ST, IT, OT, input_size, size}(0, const_initializer, 
                Func{ST, IT, OT}(
                            function (constant_pointer, inputs, outputs)
                                sum::IT = 0
                                for input in inputs
                                    sum += MathConstants.e ^ input
                                end
                                for i in 1:size
                                    outputs[i] = MathConstants.e ^ inputs[i]
                                end
                            end))
        end)
end