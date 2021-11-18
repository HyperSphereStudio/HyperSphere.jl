export PolynomialRegression

mutable struct PolynomialRegression{T}  <: AbstractMathmaticalFunction{T}
    condition_number::T
    coefficient_count
    num_vars
    precision
    coefficients::Vector{T}

    trainableSVDMatrix::Matrix{T}
    trainableOutputVector::Vector{T}
    trainableMode::Bool

    function PolynomialRegression{T}(num_vars, coefficient_count; precision=10) where T
        svdmatrix::Matrix{T} =
        output_vector::Vector{T} =
        return new{T}(Int64(num_vars), Int64(expansion_count), Int32(precision),
                    zeros(T, expansion_count), zeros(T, coefficient_count, coefficient_count), zeros(T, coefficient_count), true)
    end
end
