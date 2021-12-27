module Optimizer
    using BlackBoxOptim
    using ..Utils
    import ..ConstantPool
    import ..Error

    @Fun(Func{Iterator, T}, result_constants::ConstantPool{T}, init_constants::ConstantPool{T}, err_func::Error.Func{Iterator}, constant_bounds::Vector{Bound{T}})

    export blackboxoptimizer

    "Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea"
    function blackboxoptimizer(Iterable::Type, StorageType::Type; method::Symbol = :de_rand_1_bin)
        return Func{Iterable, StorageType}((cons_pool, error_func, cons_bounds) ->
             best_candidate(
                bboptimize(error_func, cons_pool, 
                     TraceMode = :silent, 
                     SearchRange = [(bound.lower_bound, bound.upper_bound) for bound in cons_bounds],
                     Method = method)))
    end

    
end




