#=
MultiVarPolynomial:
- Julia version:
- Author: JohnB
- Date: 2021-10-03
=#

using LinearAlgebra

export MultiVarPolynomial

mutable struct MultiVarPolynomial{T}  <: AbstractTrainable{T}
    start_degree::T
    end_degree::T
    delta_degree::T
    hyper_degree::T
    condition_number::T
    num_terms
    num_vars
    expansion_count
    precision
    coefficients::Vector{T}

    trainableSVDMatrix::Matrix{T}
    trainableOutputVector::Vector{T}
    trainableMode::Bool

    function MultiVarPolynomial{T}(num_vars, num_terms, end_degree; precision=10, start_degree=0.0) where T
        delta_degree = (end_degree - start_degree) / (num_terms - 1)
        expansion_count = binomial(num_terms + num_vars - 1, num_vars)
        svdmatrix::Matrix{T} = zeros(T, expansion_count, expansion_count)
        output_vector::Vector{T} = zeros(T, expansion_count)
        return new{T}(T(start_degree), T(end_degree), T(delta_degree), T(0), T(0), Int64(num_terms),
                    Int64(num_vars), Int64(expansion_count), Int32(precision),
                    zeros(T, expansion_count), svdmatrix, output_vector, true)
    end

    function MultiVarPolynomial{T}(inputs::AbstractMatrix{T2}, outputs::AbstractArray{T3}, num_terms, end_degree; precision=10, start_degree=0.0, trainableMode=false)::MultiVarPolynomial{T} where T where T2 where T3
        poly = MultiVarPolynomial{T}(size(inputs, 2), num_terms,
            end_degree, precision = precision, start_degree = start_degree)
        train(poly, inputs, outputs)
        if !poly.trainableMode; inactivate_training(poly); end
        poly
    end

    function (f::MultiVarPolynomial{T})(args::AbstractArray{T2}; Data_Type::Type=T) where T where T2
        product_sum::Data_Type = Data_Type(0)
        power_iterator(T, f.num_vars, f.num_terms, f.start_degree, f.delta_degree,
            function(degrees, counter)
                product = Data_Type(f.coefficients[counter])
                for var in 1:f.num_vars
                    product *= Data_Type(args[var]) ^ Data_Type(degrees[var])
                    if product == 0; break; end
                end
                product_sum += product
                return false
            end)
        product_sum
    end

    function Base.string(x::MultiVarPolynomial{T}) where T
        str = "\nMulti Variable Polynomial\n" * functionheader(x, x.num_vars)
        first_print = true
        power_iterator(T, x.num_vars, x.num_terms, x.start_degree, x.delta_degree,
            function(degrees, counter)
                coeff = x.coefficients[counter]
                if coeff ≆ 0
                    if !first_print; str *= " + "; else; first_print = false; end
                    str *= string(coeff)
                    for var in 1:x.num_vars
                        degree = degrees[var]
                        if degree ≆ 0
                            str *= "x_" * string(var)
                            if degree ≆ 1; str *= "^" * string(degree); end
                        end
                    end
                end
                return false
            end)
        str * "\nMemory Size:" * string(sizeof(x)) * "\n"
    end

    function Base.sizeof(x::MultiVarPolynomial{T}) where T
        return sizeof(MultiVarPolynomial{T}) + sizeof(x.coefficients) + (x.trainableMode ? (sizeof(x.trainableOutputVector) + sizeof(x.trainableSVDMatrix)) : 0)
    end
end

function Functions.set_trainable!(poly::MultiVarPolynomial{T}) where T
    poly.trainableMode = false
    poly.trainableSVDMatrix = zeros(0, 0)
    poly.trainableOutputVector = zeros(0)
end

function Functions.train!(f::MultiVarPolynomial{T}, inputs::AbstractMatrix{T2}, outputs::AbstractVector{T3}) where T where T2 where T3
    if !f.trainableMode; error("Polynomial is not trainable"); end
    training_out = _train(inputs, outputs, f.num_vars, f.num_terms, f.start_degree, f.delta_degree, f.precision, f.trainableSVDMatrix, f.trainableOutputVector)
    f.coefficients = training_out[1]
    degree_sum::T = T(0)
    power_iterator(T, f.num_vars, f.num_terms, f.start_degree, f.delta_degree,
        function(degrees, idx)
            degree_sum += f.coefficients[idx] * sum(degrees)
            return false
        end)
    f.hyper_degree = sum(f.coefficients) / degree_sum
    f.condition_number = training_out[2]
end

"""Iterates through all the power combinations of the polynomial
"""
function power_iterator(T::Type, num_vars, num_terms, start_degree, delta_degree, iteration_lambda::Function)
    running_count = 1
    max_vector = zeros(typeof(num_vars), num_vars)
    sum_vector = zeros(typeof(num_vars), num_vars)
    index_vector = zeros(typeof(num_vars), num_vars)
    power_vector = zeros(T, num_vars)
    for i in 0:(num_terms - 1)
        partition(i, num_vars,
            function(indexes, idx)
                power_vector .= (indexes .* delta_degree) .+ start_degree
                b = iteration_lambda(power_vector, running_count)
                running_count += 1
                return b
            end, max_vector=max_vector, sum_vector=sum_vector, index_vector=index_vector)
        fill!(max_vector, 0)
        fill!(sum_vector, 0)
        fill!(index_vector, 0)
    end
end

function _train(inputs::AbstractMatrix{T2}, outputs::AbstractVector{T3}, num_vars, num_terms, start_degree, delta_degree, precision, svdmatrix::Matrix{T}, output_vector::Vector{T}) where T where T2 where T3
    if size(inputs, 1) != length(outputs); error("Data Mismatch. InputSize:" * string(size(inputs, 1)) * " Output Size:" * string(length(outputs))); end
    if size(inputs, 2) < num_vars; error("Dimension Mismatch: Var Input Size:" * string(size(inputs, 2)) * " Cached Var Size:" * string(num_vars)); end
    if length(outputs) == 0; return; end
    power_iterator(T, num_vars, num_terms, start_degree, delta_degree,
        function(row_powers, row)
            power_iterator(T, num_vars, num_terms, start_degree, delta_degree,
                function(col_powers, col)
                    if col >= row
                        summed_degrees = row_powers + col_powers
                        product_sum = svdmatrix[row, col]
                        if row == 1; output_product_sum = output_vector[col]; end
                        for data_entry_index in 1:length(outputs)
                            product::T = 1
                            for var in 1:num_vars
                                degree = summed_degrees[var]
                                product *= inputs[data_entry_index, var] ^ degree
                                if product == 0
                                    break
                                end
                            end
                            product_sum += product
                            if row == 1; output_product_sum += outputs[data_entry_index] * product; end
                        end
                        svdmatrix[row, col] = product_sum
                        svdmatrix[col, row] = product_sum
                        if row == 1; output_vector[col] = output_product_sum; end
                    end
                    return false
                end)
            return false
        end)
    inv_svd = pinv(svdmatrix)
    (round.(inv_svd * output_vector, digits = precision), norm(svdmatrix) * norm(inv_svd))
end



