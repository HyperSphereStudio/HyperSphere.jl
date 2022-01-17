#Written By Johnathan Bizzano
module Optimizer
    using ..Utils
    import ..ConstantPool
    import ..Error
    using ..Computation

    @Fun(Problem, output::Float64, new_constants::AbstractArray)

    include("DeRand1Bin.jl")

    function copywraperror(cons, err_func::Error.WrappedFunc)
        Problem(
            function (constants)
                copy!(cons, constants)
                return err_func()
            end)
    end
    

    function de_rand_1_bin(; population_size, iterations, scalefactor = .8, crossoverrate = .7, rnginterval = 1E-8, IsVerbose=true)
        return MemoryWrapper(sett -> 
                    function (cons_pool, error_func, lower_bound, upper_bound)
                        return diffevorandomsinglebin(sett.device, copywraperror(cons_pool, error_func), copy(cons_pool), 
                                lower_bound, upper_bound, population_size,
                                iterations, scalefactor=scalefactor, crossoverrate=crossoverrate, 
                                rnginterval=rnginterval, IsVerbose=IsVerbose)
                    end)
    end

end




