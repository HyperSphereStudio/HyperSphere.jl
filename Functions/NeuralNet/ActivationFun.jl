#Written By Johnathan Bizzano
module Activation
    import ..@Fun
    import ...CommonStaticFunctions.Single

    export Sigmoid, Tanh, ZeroMax, ZeroMin, RELU, LeakyRELU

    @Fun(Func{InputType, OutputType}, out::OutputType, in::InputType)
    @Fun(Wrapper, Func, InputType::Type, OutputType::Type)

    Sigmoid() = Wrapper((IT, OT) -> Func{IT, OT}(Single.Sigmoid(IT, OT)))
    Tanh() = Wrapper((IT, OT) -> Func{IT, OT}(Single.Tanh(IT, OT)))
    ZeroMax() = Wrapper((IT, OT) -> Func{IT, OT}(Single.RMax(IT, OT, 0)))
    ZeroMin() = Wrapper((IT, OT) -> Func{IT, OT}(Single.RMin(IT, OT, 0)))
    LeakyRELU(slope) = Wrapper((IT, OT) -> Func{IT, OT}(Single.LeftValuePieceWise(IT, OT, [Linear(slope, 0), Linear(1, 0)], [0])))
    None() = Wrapper((IT, OT) -> Func{IT, OT}(x -> OT(x)))

    #Aliases
    RELU() = ZeroMax()
end

