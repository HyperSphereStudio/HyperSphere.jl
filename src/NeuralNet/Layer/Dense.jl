#Written By Johnathan Bizzano

function dense_kernel(inputs, constant_row, activ, idx)
    sum = 0.0
    for i in 1:row_len
        sum += inputs[i] * constant_row[idx + i]
    end
    activ(sum)
end

function Dense(size, initializer; activation=Activation.None())
    return LayerGenerator(
        function(pb, sett, input_shape)
                indexes = prealloc_readonly!(pb, [(i - 1) * size for i in 1:size])
                activ = activation(sett)
                device = sett.device

                LayerDesign(Sig(:DenseLayer), input_shape, (size), (size, size), initializer, 
                        LayerInitializer(
                            function (inputs, outputs, constants)
                                indexes = indexes()
                                inputs = Ref(inputs)
                                constants = Ref(constants)
                                return () -> broadcast!(dense_kernel, outputs, inputs, constants, activ, size, indexes)
                            end))
    end)
end

export DenseLayer
DenseLayer(size, initializer; activation=Activation.None()) = Dense(size, initializer; activation=activation)