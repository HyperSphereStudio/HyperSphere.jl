import Main.HyperSphere
import Main.HyperSphere.Functions
import Main.HyperSphere.Utils
import Main.HyperSphere.HyperDimensional
import Main.HyperSphere.HSMath

export SeriesApprox

mutable struct SeriesApprox{T}  <: AbstractMathmaticalFunction{T}
    start_degree::T
    end_degree::T
    delta_degree::T
    condition_number::T
    num_terms
    num_vars
    precision
    coefficients::Vector{T}

    trainableSVDMatrix::Matrix{T}
    trainableOutputVector::Vector{T}
    trainableMode::Bool

    function SeriesApprox{T}(num_vars, num_terms, end_degree; precision=10, start_degree=0.0) where T
        return new{T}(T(start_degree), T(end_degree), T(end_degree - start_degree) / (num_terms - 1), T(0), Int64(num_terms),
                    Int64(num_vars), Int32(precision),
                    zeros(T, num_vars * num_terms), zeros(T, num_vars * num_terms, num_vars * num_terms), zeros(T, num_vars * num_terms), true)
    end

    function SeriesApprox{T}(inputs::AbstractMatrix{T2}, outputs::AbstractArray{T3}, num_terms, end_degree; precision=10, start_degree=0.0, trainableMode=false)::SeriesApprox{T} where T where T2 where T3
        poly = SeriesApprox{T}(size(inputs, 2), num_terms,
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

    
end
