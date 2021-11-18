import Main.HyperSphere
import Main.HyperSphere.Functions
import Main.HyperSphere.Utils
import Main.HyperSphere.HyperDimensional
import Main.HyperSphere.HSMath

export LinearFixedLengthNeuralNet, basic_poly_initializer, reals_to_reals

function basic_poly_initializer(num_terms, end_degree; precision=10, start_degree=0.0, Data_Type=Float32)
    input_length -> Functions.MultiVarPolynomial{Data_Type}(input_length, num_terms, end_degree, precision = precision, start_degree = start_degree)
end

function reals_to_reals(num_polys, input_length, num_terms, end_degree; output_length = 1, precision=10, start_degree=0.0, Data_Type=Float32)
    return HyperSphere.LinearFixedLengthNeuralNet{Data_Type}(num_polys, input_length,
        function (value, output_vector, index)
            push!(output_vector, value)
            return length(output_vector) == output_length
        end,
        (value, row, col, is_terminating) -> value, HyperSphere.basic_poly_initializer(num_terms, end_degree, precision = precision, start_degree = start_degree, Data_Type = Data_Type))
end

struct LinearFixedLengthNeuralNet{T} <: AbstractNeuralNet{T}
    
    polynomials::Array{Functions.MultiVarPolynomial{T}, 1}
    input_length
    mapping_function::Function
    demapping_function::Function

    """mapping function (polynomial_output::Number, output_vector::AbstractVector, polynomial_index::Number) -> real_output::Number
       demapping function (real_output::Number, output_row_index::Number, output_col_index::Number, is_terminating::Bool) -> polynomial_output::Number
       poly_initializer (input_length::Integer) -> Functions.MultiVarPolynomial{Poly_Data_Type}
    """
    function LinearFixedLengthNeuralNet{T}(num_polys, input_length,
        mapping_function::Function,
        demapping_function::Function,
        poly_initializer::Function) where T
        return new{T}([poly_initializer(input_length + i) for i in 1:num_polys ], input_length, mapping_function, demapping_function)
    end

    function (f::LinearFixedLengthNeuralNet{T})(args::AbstractArray{T2}; Data_Type::Type = T) where T where T2
        outputs = Vector{Data_Type}(undef, 0)
        inputs = Vector{T}(undef, f.input_length + length(f.polynomials))
        index = 1

        for v in 1:length(args); inputs[v] = T(args[v]); end
        while true
            value = 0
            for i in 1:length(f.polynomials)
                inputs[f.input_length + 1] = i - 1
                value = f.polynomials[i](inputs, Data_Type = Data_Type)
                if i != length(f.polynomials)
                    inputs[f.input_length + i + 1] = HSMath.powi(value, f.polynomials[i].hyper_degree)
                end
            end
            if f.mapping_function(value, outputs, index); return outputs; end
            index += 1
        end
    end

    function Base.string(x::LinearFixedLengthNeuralNet)
        str = "Linear Fixed Length Neural Net\nPolynomial Count:" * string(length(x.polynomials)) * "\tInput Length:" * string(x.input_length) * "\n"
        for idx in 1:length(x.polynomials)
            str *= "Polynomial #$idx:" * string(x.polynomials[idx]) * "\n"
        end
        str
    end

    function Base.sizeof(x::LinearFixedLengthNeuralNet{T}) where T
        sum = sizeof(LinearFixedLengthNeuralNet{T})
        for poly in x.polynomials
            sum += sizeof(poly)
        end
        return sum
    end
end

function Functions.inactivate_training(f::LinearFixedLengthNeuralNet{T}) where T
    for poly in f.polynomials
        inactivate_training(poly)
    end
end

function Functions.train(f::LinearFixedLengthNeuralNet{T}, input_data::AbstractMatrix{T2}, output_data::AbstractArray{T3}; Data_Type::Type = T)  where T where T2 where T3
    data_length = size(input_data, 1)
    if data_length != length(output_data)
        HyperDimensional.DimensionException("Data Mismatch", data_length, length(output_data))
    end
    if size(input_data, 2) < f.input_length
        HyperDimensional.DimensionException("Data Mismatch", data_length, f.input_length)
    end
    output_training_vector = Array{Data_Type, 1}(undef, data_length)
    input_training_matrix = zeros(T, data_length, f.input_length + length(f.polynomials))

    index = 1
    for row in 1:data_length
        for col in 1:f.input_length
            input_training_matrix[row, col] = T(input_data[row, col])
        end
    end

    while data_length > 0
        terminating_indexes = []
        for i in 1:data_length
            output_training_vector[i] = f.demapping_function(output_data[i][index], i, index, index == length(output_data[i]))
            if index == length(output_data[i]); push!(terminating_indexes, i); end
        end

        for i in 1:length(f.polynomials)
            input_training_matrix[1:end, f.input_length + 1] .= index
            Functions.train(f.polynomials[i], input_training_matrix, output_training_vector)
            if i != length(f.polynomials)
                for d in 1:data_length
                    input_training_matrix[d, f.input_length + i + 1] = HSMath.powi(f.polynomials[i](input_training_matrix[d, 1:(f.input_length + i)]), f.polynomials[i].hyper_degree)
                end
            end
        end

        HyperDimensional.buffer_remove_row(output_training_vector, terminating_indexes, data_length)
        HyperDimensional.buffer_remove_row(output_data, terminating_indexes, data_length)
        data_length = HyperDimensional.buffer_remove_row(input_training_matrix, terminating_indexes, data_length)[2]
        index += 1
    end
end
