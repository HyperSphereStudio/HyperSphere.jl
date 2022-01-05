module Processor
    using ...Utils
    using ...CommonStaticFunctions.Single

    export None, ArgMaxIdx, SingleFunc, Chain

    @VFun(Func, output::Any, input::Any, outputs)

    None() = MemoryWrapper(Sig(:None), sett -> Func(in -> in))

    ArgMaxIdx() = MemoryWrapper(Sig(:ArgMaxIdx), 
                  function (sett)
                        T = sett.outputType
                        Func(
                            function (in)
                                maxIdx = 1
                                maxVal::T = -Inf
                                for i in eachindex(in)
                                    if in[i] > maxVal
                                        maxVal = in[i]
                                        maxIdx = i
                                    end
                                end
                                return T(maxIdx)
                            end)
                end)


    SingleFunc(singleFunc::Single.Wrapper) = MemoryWrapper(Sig(:SingleFunc), 
        function (sett)
            func = singleFunc(I, O)
            return Func(
                function (input)
                   
                end)
            end)

    "Chain together processors. f(g(...h(x))) = Chain(f, g, ...h)."    
    Chain(processors...) = MemoryWrapper(Sig(:Chain), 
        function (sett)
            procs = [processors[i](sett) for i in length(processors):-1:1]
            return Func(
                function (input)
                    out = input
                        for proc in procs
                            out = proc(out)
                        end
                        out
                    end)
        end)

end



    