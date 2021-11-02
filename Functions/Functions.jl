module Functions
    include("../CoreHS/CoreHS.jl")
    using .CoreHS

    include("../Utilities/Utils.jl")
    using .Utils

    include("../HyperDimensional/HyperDimensional.jl")
    using .HyperDimensional

    include("AbstractMathmaticalFunction.jl")
    export AbstractMathmaticalFunction

    include("MultiVarPolynomial.jl")
    export MultiVarPolynomial
    export train, memorysizeof
end
