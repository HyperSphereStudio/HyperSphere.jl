export Layer

struct Layer{T} <: AbstractNeuralNet{T}
    constant_count::T
    preprocessor::Function
    node_function::Function

    function Layer(constant_count::T, preprocessor::Function, node_function::Function) where T
        new{T}(constant_count, preprocessor, node_function)
    end

    function (l::Layer{T})(constant_pointer::Ptr{T}, output_array::Vector{T2}, args::AbstractArray{T2}; Data_Type::Type = T)::Bool where T where T2
        return l.node_function(l, constant_pointer, l.preprocessor(l, args), output_array)
    end

end
