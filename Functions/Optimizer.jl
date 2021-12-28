module Optimizer
    using ..Utils
    import ..ConstantPool
    import ..Error
    import ...MVector

    @Fun(Func{StorageType, OutputType}, result_constants::ConstantPool{StorageType}, init_constants::ConstantPool{StorageType}, err_func::Error.Func{OutputType}, constant_bounds::Vector{Bound{StorageType}})
    @Fun(Wrapper, Func, StorageType::Type, OutputType::Type)

    export blackboxoptimizer

    using BlackBoxOptim

    function copywraperror(cons, err_func::Error.Func{T}) where T
        const_count = length(cons)
        Error.Func{T}(
            function (constants)
                for i in 1:const_count
                    cons[i] = constants[i]
                end
                return err_func()
            end)
    end

    "Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea"
    function blackboxoptimizer(; method::Symbol = :de_rand_1_bin)
        return Wrapper((ST, OT) -> 
                Func{ST, OT}(
                    function (cons_pool, error_func, cons_bounds)
                        res = best_candidate(
                            bboptimize(copywraperror(cons_pool, error_func), cons_pool, 
                                TraceMode = :silent, 
                                SearchRange = [(bound.lower_bound, bound.upper_bound) for bound in cons_bounds],
                                Method = method))
                        copy!(cons_pool, res)
                        res
                    end))
    end



end




