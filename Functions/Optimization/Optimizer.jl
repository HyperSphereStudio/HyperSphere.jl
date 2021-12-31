"Written By Johnathan Bizzano"
module Optimizer
    using ..Utils
    import ..ConstantPool
    import ..Error
    import ...MVector
    
    include("DeRand1Bin.jl")

    @Fun(Func{StorageType, OutputType}, result_constants::ConstantPool{StorageType}, init_constants::ConstantPool{StorageType}, err_func::Error.Func{OutputType}, constant_bounds::Array{Bound{StorageType}})
    @Fun(Wrapper, Func, StorageType::Type, OutputType::Type)

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
    

    function de_rand_1_bin(; population_size, iterations, scalefactor = .8, crossoverrate = .7, rnginterval = 1E-8)
        return Wrapper((ST, OT) -> 
                Func{ST, OT}(
                    function (cons_pool, error_func, cons_bounds)
                        res = diffevorandomsinglebin(copywraperror(cons_pool, error_func), copy(cons_pool), cons_bounds, population_size,
                             iterations, scalefactor = scalefactor, crossoverrate = crossoverrate, rnginterval = rnginterval)
                        copy!(cons_pool, res)
                        return res
                    end))
    end

end




