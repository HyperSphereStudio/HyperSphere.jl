export UniformNodeSetLayer

function UniformNodeSetLayer(const_initializer, wrapper::Nodes.Wrapper; input_size::Int, output_size::Int)
    return Wrapper(
        function (ST, IT, OT)
            node = wrapper(ST, IT, OT)
            nodef = node.fun
            nodem = node.merge
            nodea = node.activation
            Layer{ST, IT, OT, input_size, output_size}(node.constant_size * output_size, const_initializer, 
                Func{ST, IT, OT}(
                            function (constant_pointer, inputs, outputs)
                                for i in 1:output_size
                                    outputs[i] = nodea(nodef(constant_pointer, nodem(inputs, i)))
                                    increment!(constant_pointer, node.constant_size)
                                end
                            end))
        end)
end