#Written By Johnathan Bizzano
module Activation
    import ..@Fun
    import ...Functions.CommonStaticFunctions.Single

    export Sigmoid, Tanh, ZeroMax, ZeroMin, RELU, LeakyRELU

    Sigmoid() = Single.Sigmoid()
    Tanh() = Single.Tanh()
    ZeroMax() = Single.RMax(0)
    ZeroMin() = Single.RMin(0)
    LeakyRELU(slope) = Single.LeftValuePieceWise([Single.Linear(slope, 0), Single.Linear(1, 0)], [0])
    None() = MemoryWrapper(sett -> (x -> x))

    #Aliases
    RELU() = ZeroMax()
end

