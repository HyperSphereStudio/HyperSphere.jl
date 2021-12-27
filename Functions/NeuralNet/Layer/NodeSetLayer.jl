export NodeSetLayer

function NodeSetLayer(T::Type, input_size::Int, nodes::AbstractArray{Nodes.Node}, const_initializer)::Layer{T, input_size, length(nodes)}
    Layer{T, input_size, output_size}(node.constant_size * size, const_initializer, 
        Func{T}(
            function (constant_pointer, inputs, outputs)
                for node in nodes
                    outputs[i] = node(constant_pointer, inputs)
                end
            end))
end