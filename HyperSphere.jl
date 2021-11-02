module HyperSphere
    import Pkg
    using Reexport

    include("CoreHS/CoreHS.jl")
    @reexport using .CoreHS

    include("Utilities/Utils.jl")
    @reexport using .Utils

    include("HyperDimensional/HyperDimensional.jl")
    @reexport using .HyperDimensional

    include("Functions/Functions.jl")
    @reexport using .Functions

    include("Math/Math.jl")
    @reexport using .HSMath

    function install()
        Pkg.add("Reexport")
    end
end

function memorysizeof(x)
    return HyperSphere.memorysizeof(x)
end
