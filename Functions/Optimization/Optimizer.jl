export Optimizer

export blackboxoptimizer

const Optimizer{Iterator, T} = Fun{ConstantPool{T}, Tuple{ConstantPool{T}, ErrorFunction{Iterator}, Vector{Bound{T}}}} 


using BlackBoxOptim

"Methods = adaptive_de_rand_1_bin, adaptive_de_rand_1_bin_radiuslimited, separable_nes, xnes, de_rand_1_bin, de_rand_2_bin, de_rand_1_bin_radiuslimited, de_rand_2_bin_radiuslimited, random_search, generating_set_search, probabilistic_descent, borg_moea"
function blackboxoptimizer(Iterator::Type, StorageType::Type, method::Symbol = :de_rand_1_bin)
    return Optimizer{Iterator, StorageType}((args) ->
             args[2](best_candidate(
                bboptimize(func, args[1], 
                     TraceMode = :silent, 
                     SearchRange = [(lower_bound(bound), upper_bound(bound)) for bound in args[3]],
                     Method = method))))
end
