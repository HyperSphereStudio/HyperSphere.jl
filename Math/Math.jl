module HSMath

    export powi, optimize, offset_func, offset_calc, cplx_floor, cplx_ceil, cplx_mod, ∏, ∑, ≆, ≊

    include("Primes.jl")

    powi(base, pow) = base < 0 ? -((-base) ^ pow) : base ^ pow

    """f -> Function in modifying g(x)
       g -> Internal Core Function
       o -> Operator function

       Returns required such that O(f(g(x))) = f(g(x) + C). Solves for C
    """

    ≆(x, p) = !isapprox(x, p)
    ≊(x, p) = isapprox(x, p)

    offset_func(f::Function, f_inv::Function, g::Function, operator::Function) = x -> offset_calc(x, f, f_inv, g, operator)

    offset_calc(x, f::Function, f_inv::Function, g::Function, operator::Function) = f_inv(operator(f(g(x)))) - g(x)

    cplx_floor(x) = Base.floor(real(x)) + Base.floor(imag(x)) * im

    cplx_ceil(x) = Base.ceil(real(x)) + Base.ceil(imag(x)) * im

    cplx_mod(base, num) = base - num * cplx_floor(base / num)

    function ∏(array::NTuple{N, T}) where {T, N}
        prod::T = 1
        for arg in array
            prod *= arg
        end
        prod
    end

    function ∏(array::AbstractArray{T}) where T
        prod::T = 1
        for arg in array
            prod *= arg
        end
        prod
    end

    function ∑(array::AbstractArray{T}) where T
        sum::T = 0
        for arg in array
            sum += arg
        end
        sum
    end

    function ∑(array::NTuple{N, T}) where {T, N}
        sum::T = 0
        for arg in array
            sum += arg
        end
        sum
    end
end
