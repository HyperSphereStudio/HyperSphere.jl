module Activation
    import ..@Fun
    import ...CommonStaticFunctions.Single

    export Sigmoid, Tanh, ZeroMax, ZeroMin, RELU, LeakyRELU

    @Fun(Func{T}, T, T)

    Sigmoid(T::Type) = Func{T}(Single.Sigmoid(T))
    Tanh(T::Type) = Func{T}(Single.Tanh(T))
    ZeroMax(T::Type) = Func{T}(Single.RMax(T, 0))
    ZeroMin(T::Type) = Func{T}(Single.RMin(T, 0))
    LeakyRELU(T::Type, slope) = Func{T}(Single.LeftValuePieceWise([Linear(T, slope, 0), Linear(T, 1, 0)], [0]))

    #Aliases
    RELU(T::Type) = ZeroMax(T)
end

