function ElementWise(fun::MemoryWrapper)
    return LayerGenerator(
        function(pb, sett, input_shape)
                f = fun(sett)
                LayerDesign(Sig(:ElementWise), input_shape, input_shape, (0), nothing, 
                    LayerInitializer(
                        function (ins, outs, cons)
                            return function ()
                                broadcast!(f, outs, ins)
                            end
                        end))
        end)
end

export ElementWiseLayer
ElementWiseLayer(fun::Function) = ElementWise(fun)