module HSMath

    import BlackBoxOptim
    export powi, optimize

    include("Series.jl")
    include("Primes.jl")
    include("VMath.jl")

    powi(base, pow) = base < 0 ? -((-base) ^ pow) : base ^ pow


    """ Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea
    """
    optimize(func::Function, SearchRange, NumDims) = BlackBoxOptim.best_candidate(BlackBoxOptim.bboptimize(func, TraceMode = :silent, SearchRange = SearchRange, NumDimensions = NumDims))
end
