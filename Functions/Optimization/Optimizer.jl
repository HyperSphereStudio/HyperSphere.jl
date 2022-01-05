#Written By Johnathan Bizzano
module Optimizer
    using ..Utils
    import ..ConstantPool
    import ..Error
    import ...MVector

    @Fun(Func{DeviceArray, StorageType}, result_constants::Tuple{DeviceArray, Float64}, 
            init_constants::DeviceArray, err_func::Error.WrappedFunc,
            lower_constant_bound::StorageType, upper_constant_bound::StorageType)

    @Fun(Problem{DeviceArray, StorageType}, output::Float64, new_constants::DeviceArray)

    include("DeRand1Bin.jl")

    function copywraperror(cons::A, err_func::Error.WrappedFunc) where {A}
        Problem{A}(
            function (constants)
                copy!(cons, constants)
                return err_func()
            end)
    end
    

    function de_rand_1_bin(; population_size, iterations, scalefactor = .8, crossoverrate = .7, rnginterval = 1E-8, IsVerbose=true)
        return MemoryWrapper(sett -> Func{sett.deviceArray, sett.storageType}(
                    function (cons_pool, error_func, lower_bound, upper_bound)
                        return diffevorandomsinglebin(sett.device, copywraperror(cons_pool, error_func), copy(cons_pool), 
                                lower_bound, upper_bound, population_size,
                                iterations, scalefactor=scalefactor, crossoverrate=crossoverrate, 
                                rnginterval=rnginterval, IsVerbose=IsVerbose)
                    end))
    end

end




