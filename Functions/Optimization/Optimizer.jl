using BlackBoxOptim

export Optimizer, bboptimizer

struct InternalOptimizer{T <: Type} <: Fun{Array{T, 1}, Tuple{ErrorFunction}} end


struct Optimizer{T <: Type}
    _optimizer::InternalOptimizer{T}

    function Optimizer()
        new(method, search_range)
    end

    function (o::Optimizer)(constants::Array{T, 1}, func::Function) where T
        _optimizer(constants, func)
    end
end


""" Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea
"""
function bboptimizer(method::Symbol = :de_rand_1_bin, search_range::UnitRange{Float64} = (-1, 1))
    return InternalOptimizer((constants::Array, func::Function) -> func(best_candidate(bboptimize(func, constants, TraceMode = :silent, SearchRange = search_range, Method = o.method))))
end
