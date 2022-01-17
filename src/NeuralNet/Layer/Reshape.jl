#Written By Johnathan Bizzano

function Reshape(output_shape)
    return LayerGenerator(
        function(pb, sett, input_shape)
                LayerDesign(Sig(:ReshapeLayer), input_shape, output_shape, (0), nothing, LayerInitializer(Reshape))
        end)
end

export ReshapeLayer
ReshapeLayer(output_shape) = Reshape(output_shape)