export UniformNodeSetLayer

function UniformNodeSetLayer(T::Type, input_size::Int, size::Int, node::Nodes.Node, const_initializer)::Layer{T, input_size, size}
    nodef = node.fun
    nodem = node.merge
    nodea = node.activation
    Layer{T, input_size, size}(node.constant_size * size, const_initializer, 
        Func{T}(
            function (constant_pointer, inputs, outputs)
                input = nodem(inputs)
                for i in 1:size
                    outputs[i] = nodea(nodef(constant_pointer, input))
                end
            end))
end