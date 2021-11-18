export Gen3NetDesigner


mutable struct Gen3NetDesigner{T}
        input_length::T
        output_length::T
        layers::Vector{Layer}
        init_constant_vector::Vector{T}

        mapper::Function
        demapper::Function
        error_function::Function
        optimizer::Function
end

struct Gen3Net{T} <: AbstractNeuralNet{T}
        input_length::T
        output_length::T
        layers::Array{Layer, 1}
        constants::Array{T, 1}

        mapper::Function
        demapper::Function
        error_function::Function
        optimizer::Function

        function Gen3Net{T}(designer::Gen3NetDesigner{T}) where T
                sum = 0
                for l in designer.layers
                        sum += l.constant_count
                end
                new{T}(designer.input_length, designer.output_length, layers,
                        designer.init_constant_vector, designer.mapper,
                        designer.demapper, designer.error_function, designer.optimizer)
        end

        function (f::Gen3Net{T})(args::AbstractArray{T2}; Data_Type::Type = T) where T where T2
                const_ptr = pointer(f.constants)
                output_vec = Data_Type[]
                for l in f.layers
                        args = l(const_ptr, output_vec, args, Data_Type=Data_Type)
                        const_ptr += l.constant_count
                end
                f.mapper(f, output_vec)
        end
end

function train(f::Gen3Net{T}, input_data::AbstractMatrix{T2}, output_data::AbstractArray{T3}; Data_Type::Type = T)  where T where T2 where T3
     
end
