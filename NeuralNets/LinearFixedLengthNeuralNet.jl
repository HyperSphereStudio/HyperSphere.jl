import Main.HyperSphere
import Main.HyperSphere.Functions
import Main.HyperSphere.Utils
import Main.HyperSphere.HyperDimensional

export LinearFixedLengthNeuralNet, basic_poly_initializer, reals_to_real



function basic_poly_initializer(num_terms, end_degree; precision=10, start_degree=0.0, Data_Type=Float32)
    (input_length, idx) -> Functions.MultiVarPolynomial{Data_Type}(input_length + idx, num_terms, end_degree, precision = precision, start_degree = start_degree)
end

function reals_to_real(num_polys, input_length, num_terms, end_degree; precision=10, start_degree=0.0, Data_Type=Float32)
    return HyperSphere.LinearFixedLengthNeuralNet{Data_Type}(num_polys, input_length,
        function (value, output_vector, index)
            push!(output_vector, value)
            return true
        end,
        function (value, row, col, is_terminating)
            return value
        end, HyperSphere.basic_poly_initializer(num_terms, end_degree, precision = precision, start_degree = start_degree, Data_Type = Data_Type))
end

struct LinearFixedLengthNeuralNet{T} <: AbstractNeuralNet
    polynomials::Array{Functions.MultiVarPolynomial{T}, 1}
    inputlength
    mapping_function::Function
    demapping_function::Function

    """mapping function (polynomial_output::Number, output_vector::AbstractVector, polynomial_index::Number) -> real_output::Number
       demapping function (real_output::Number, output_row_index::Number, output_col_index::Number, is_terminating::Bool) -> polynomial_output::Number
       poly_initializer (input_length::Integer, poly_idx::Integer) -> Functions.MultiVarPolynomial{Poly_Data_Type}
    """
    function LinearFixedLengthNeuralNet{T}(num_polys, inputlength,
        mapping_function::Function,
        demapping_function::Function,
        poly_initializer::Function) where T
        return new{T}([poly_initializer(inputlength, i) for i in 1:num_polys], inputlength, mapping_function, demapping_function)
    end

    function (f::LinearFixedLengthNeuralNet{T})(args::AbstractArray{T2}; Data_Type::Type = T) where T where T2
        outputs = Vector{Data_Type}(undef, 0)
        inputs = Vector{T}(undef, f.inputlength + length(f.polynomials))
        arglen = length(args)
        index = 0
        for v in 1:arglen; inputs[v] = T(args[v]); end
        while true
            value = 0
            for i in 1:length(f.polynomials)
                inputs[arglen + 1] = i - 1
                value = f.polynomials[i](inputs, Data_Type = Data_Type)
                if i != length(f.polynomials)
                    inputs[arglen + i + 1] = value
                end
            end
            if f.mapping_function(value, outputs, index); return outputs; end
            index += 1
        end
    end

    function Base.string(x::LinearFixedLengthNeuralNet)
        return "Linear Fixed Length Neural Net\n\tPolynomial Count:" * string(length(x.polynomials)) * "\tInput Length:" * string(x.inputlength) * "\n" * string(x.polynomials)
    end
end

function Functions.inactivate_training(f::LinearFixedLengthNeuralNet{T}) where T
    for poly in f.polynomials
        inactivate_training(poly)
    end
end

function Functions.train(f::LinearFixedLengthNeuralNet{T}, input_data::AbstractMatrix{T2}, output_data::AbstractArray{T3}; OutDataType::Type = T)  where T where T2 where T3
    data_length = size(input_data, 1)
    if data_length != length(output_data)
        HyperDimensional.DimensionException("Data Mismatch", data_length, length(output_data))
    end
    if size(input_data, 2) < f.inputlength
        HyperDimensional.DimensionException("Data Mismatch", data_length, f.inputlength)
    end

    input_vector = Array{T, 1}(undef, f.inputlength + length(f.polynomials))
    output_training_vector = Array{OutDataType, 1}(undef, data_length)
    input_training_matrix = Array{T, 2}(undef, data_length, f.inputlength + length(f.polynomials) + 1)
    index = 1

    for row in 1:data_length
        for col in 1:f.inputlength
            input_training_matrix[row, col] = T(input_data[row, col])
        end
    end

    while data_length > 0
        input_vector[f.inputlength + 1] = index - 1
        input_training_matrix[1:end, f.inputlength + 1] .= index - 1
        terminating_indexes = []
        for i in 1:data_length
            output_training_vector[i] = f.demapping_function(output_data[i][index], i, index, index == length(output_data[i]))
            if index == length(output_data[i]); push!(terminating_indexes, i); end
        end
        Functions.train(f.polynomials[index], input_training_matrix, output_training_vector)
        for i in 1:data_length
            input_vector[(f.inputlength + 2):end] = input_training_matrix[i, (f.inputlength + 2):end]
            if i != data_length
                input_training_matrix[i, f.inputlength + 1 + index] = f.polynomials[index](input_vector)
            end
        end
        HyperDimensional.buffer_remove_dimension_parts(output_training_vector, terminating_indexes, data_length)
        data_length = HyperDimensional.buffer_remove_dimension_parts(input_training_matrix, terminating_indexes, data_length)[2]
        index += 1
    end
end
