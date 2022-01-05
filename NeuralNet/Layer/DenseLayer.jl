#Written By Johnathan Bizzano
export DenseLayer

sum_el(temp, idx, input_shape, activ) = activ(sum(view(temp, idx, 1:input_shape)))

function DenseLayer(size, initializer; activation=Activation.None())
    return ParallelWrapper(
        function(sett, input_shape)
                indexes = alloc(sett.device, collect(1:size))
                activ = activation(sett)
                device = sett.device

                LayerDesign(Sig(:DenseLayer), input_shape, (size, 1), input_shape[1] * size, initializer, 
                    Generator(
                        function (ins, outs, cons)
                            temp = alloc(device, size, input_shape[1])

                            return function ()
                                    broadcast!(*, temp, constants, ins)
                                    broadcast!(sum_el, outs, Ref(temp), indexes, input_shape[1], activ)
                                end
                        end))
        end
end