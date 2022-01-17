
"Perform Matrix Operations Such as a convolutional layer followed by a pooling layer applied on the filters"
function MatrixWise(layer::LayerGenerator)
    return LayerGenerator(
        function(pb, sett, input_shape)
                filter_count = input_shape[end]
                design = layer(pb, sett, (input_shape[1:(end - 1)]))
                
                LayerDesign(Sig(:MatrixWise), input_shape, input_shape, (design.constant_shape..., filter_count), nothing, 
                    LayerInitializer(
                        function (ins, outs, cons)
                            collection = [design.layer_init(view(ins, design.input_shape..., i), view(outs, design.output_shape..., i), view(cons, design.constant_shape..., i)) for i in 1:filter_count]
                            return function ()
                                for item in collection
                                    item()
                                end
                            end
                        end))
        end)
end

export MatrixWiseLayer
MatrixWiseLayer(layer::LayerGenerator) = MatrixWise(fun)