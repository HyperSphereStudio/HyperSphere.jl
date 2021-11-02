#=
MultiVarPolynomial:
- Julia version:
- Author: JohnB
- Date: 2021-10-03
=#

using LinearAlgebra

mutable struct MultiVarPolynomial{T <: Real}  <: AbstractMathmaticalFunction{T}
    start_degree::Float32
    end_degree::Float32
    delta_degree::Float32
    num_terms::Int64
    num_vars::Int64
    expansion_count::Int64
    precision::Int32
    coefficients::Vector{T}

    trainableSVDMatrix::Matrix{T}
    trainableOutputVector::Vector{T}
    trainableMode::Bool

    MultiVarPolynomial(degree, coefficients::Vector{T}) where T = new{T}(0, degree, 1, degree + 1, 1, coefficients)

    function MultiVarPolynomial(inputs::Matrix{T}, outputs::Vector{T}, num_terms, end_degree; precision=10, start_degree=0, trainableMode=false)::MultiVarPolynomial{T} where T
        num_vars = size(inputs, 1)
        expansion_count = total_count(num_terms, num_vars)
        delta_degree = (end_degree - start_degree) / (num_terms - 1)
        svdmatrix::Matrix{T} = zeros(T, expansion_count, expansion_count)
        output_vector::Vector{T} = zeros(T, expansion_count)
        return new{T}(Float32(start_degree), Float32(end_degree), Float32(delta_degree), Int64(num_terms),
                    Int64(num_vars), Int64(expansion_count), Int32(precision),
                    _train(inputs, outputs, num_vars, num_terms, expansion_count,
                        start_degree, delta_degree, precision, svdmatrix, output_vector),
                    trainableMode ? svdmatrix : zeros(0, 0),
                    trainableMode ? output_vector : zeros(0),
                    trainableMode)
    end

    function (f::MultiVarPolynomial{T})(args::Vector{T})::T where T <: Real
        product_sum::T = 0
        uhditer(f.num_vars, f.num_terms,
            function(indexes, counter)
                product = f.coefficients[counter]
                for var in 1:f.num_vars
                    degree = (indexes[var] - 1) * f.delta_degree + f.start_degree
                    product *= args[var] ^ degree
                end
                product_sum += product
            end)
        product_sum
    end

    function Base.string(x::MultiVarPolynomial)
        str = "Multi Variable Polynomial\n" * functionheader(x, x.num_vars)
        first_print = true
        uhditer(x.num_vars, x.num_terms,
            function(indexes, counter)
                coeff = x.coefficients[counter]
                if coeff ≆ 0
                    if !first_print; str *= " + "; else; first_print = false; end
                    str *= string(coeff)
                    for var in 1:x.num_vars
                        degree = (indexes[var] - 1) * x.delta_degree + x.start_degree
                        if degree ≆ 0
                            str *= "x_" * string(var)
                            if degree ≆ 1; str *= "^" * string(degree); end
                        end
                    end
                end
            end)
        str * "\nMemory Size:" * string(memorysizeof(x)) * "\n"
    end
end

function memorysizeof(f::MultiVarPolynomial{T}) where T
    return sizeof(f) + sizeof(f.coefficients) + sizeof(f.trainableSVDMatrix) + sizeof(f.trainableOutputVector)
end

function train(f::MultiVarPolynomial{T}, inputs::Matrix{T}, outputs::Vector{T}) where T <: Real
    if !f.trainableMode; error("Polynomial is not trainable"); end
    f.coefficients = _train(inputs, outputs, f.num_vars, f.num_terms, f.expansion_count,
        f.start_degree, f.delta_degree, f.precision, f.trainableSVDMatrix, f.trainableOutputVector)
end

function _train(inputs::Matrix{T}, outputs::Vector{T}, num_vars, num_terms, expansion_count, start_degree, delta_degree, precision, svdmatrix::Matrix{T}, output_vector::Vector{T}) where T <: Real
    if size(inputs, 2) != length(outputs); error("Data Mismatch. InputSize:" * string(size(inputs, 1)) * " Output Size:" * string(length(outputs))); end
    if size(inputs, 1) != num_vars; error("Dimension Mismatch: Var Input Size:" * string(size(inputs, 1)) * " Cached Var Size:" * string(num_vars)); end
    if length(outputs) != 0
        uhditer(num_vars, num_terms,
            function(indexes, row)
                uhditer(num_vars, num_terms,
                    function (indexes2, col)
                        if row <= col
                            product_sum = svdmatrix[row, col]
                            if row == 1; output_product_sum = output_vector[col]; end
                            for data_entry_index in 1:length(outputs)
                                product = 1
                                for var in 1:num_vars
                                    degree = ((indexes[var] + indexes2[var] - 2) * delta_degree + start_degree)
                                    product *= inputs[var, data_entry_index] ^ degree
                                end
                                product_sum += product
                                if row == 1; output_product_sum += outputs[data_entry_index] * product; end
                            end
                            svdmatrix[row, col] = product_sum
                            svdmatrix[col, row] = product_sum
                            if row == 1; output_vector[col] = output_product_sum; end
                        end
                    end)
            end)
        end
        round.(pinv(svdmatrix) * output_vector, digits = precision)
end
