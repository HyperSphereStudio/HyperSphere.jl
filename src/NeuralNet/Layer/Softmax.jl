#Written By Johnathan Bizzano
exppow(x) = MathConstants.e ^ x
softmax(s, x) = x / s


"multinomial logistic regression and is often used as the last activation function of a neural network to 
normalize the output of a network to a probability distribution over predicted output classes - Wikipedia"
function Softmax()
    return LayerGenerator(
        function(pb, sett, input_shape)
                LayerDesign(Sig(:SoftMaxLayer), input_shape, input_shape, 0, nothing, 
                    function (ins, outs, cons)
                            return function ()
                                        broadcast!(exppow, ins, ins)
                                        broadcast!(softmax, outs, sum(ins), ins)
                                   end
                            return outs
                    end)
        end)
end


export SoftmaxLayer
SoftMaxLayer() = SoftMax()
