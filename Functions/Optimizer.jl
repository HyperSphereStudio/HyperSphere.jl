module Optimizer
    using BlackBoxOptim
    using ..Utils
    import ..ConstantPool
    import ..Error

    @Fun(Func{StorageType, OutputType}, result_constants::ConstantPool{StorageType}, init_constants::ConstantPool{StorageType}, err_func::Error.Func{OutputType}, constant_bounds::Vector{Bound{StorageType}})
    @Fun(Wrapper, Func, StorageType::Type, OutputType::Type)

    export blackboxoptimizer

    "Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea"
    function blackboxoptimizer(; method::Symbol = :de_rand_1_bin)
        return Wrapper((ST, OT) -> 
                Func{ST, OT}((cons_pool, error_func, cons_bounds) ->
                    best_candidate(
                        bboptimize(error_func, cons_pool, 
                            TraceMode = :silent, 
                            SearchRange = [(bound.lower_bound, bound.upper_bound) for bound in cons_bounds],
                            Method = method))))
    end

    
end




