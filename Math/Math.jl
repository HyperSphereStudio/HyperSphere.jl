module HSMath

    import BlackBoxOptim
    export powi, optimize, offset_func, offset_calc, cplx_floor, cplx_ceil, cplx_mod

    include("Series.jl")
    include("Primes.jl")
    include("VMath.jl")

    powi(base, pow) = base < 0 ? -((-base) ^ pow) : base ^ pow


    """ Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea
    """
    optimize(func::Function, SearchRange, NumDims) = BlackBoxOptim.best_candidate(BlackBoxOptim.bboptimize(func, TraceMode = :silent, SearchRange = SearchRange, NumDimensions = NumDims))

    """f -> Function in modifying g(x)
       g -> Internal Core Function
       o -> Operator function

       Returns required such that O(f(g(x))) = f(g(x) + C). Solves for C
    """
    offset_func(f::Function, f_inv::Function, g::Function, operator::Function) = x -> offset_calc(x, f, f_inv, g, operator)

    offset_calc(x, f::Function, f_inv::Function, g::Function, operator::Function) = f_inv(operator(f(g(x)))) - g(x)

    cplx_floor(x) = Base.floor(real(x)) + Base.floor(imag(x)) * im
    
    cplx_ceil(x) = Base.ceil(real(x)) + Base.ceil(imag(x)) * im

    cplx_mod(base, num) = base - num * cplx_floor(base / num)
end
