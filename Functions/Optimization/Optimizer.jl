export Optimizer

export blackboxoptimizer

const Optimizer{T} = Fun{ConstantPool{T}, Tuple{ConstantPool{T}, ErrorFunction{T}, Vector{Bound{T}}}} 


using BlackBoxOptim

"Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea"
function blackboxoptimizer(method::Symbol = :de_rand_1_bin, DataType=Float64)
    return Optimizer{DataType}((constants, func, bounds) ->
             func(best_candidate(
                bboptimize(func, constants, 
                    TraceMode = :silent, 
                    SearchRange = [(lower_bound(bound), upper_bound(bound)) for bound in bounds],
                     Method = method))))
end
