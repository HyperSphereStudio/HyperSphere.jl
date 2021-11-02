module HyperDimensional
    include("../Utilities/Utils.jl")
    using .Utils

    include("Iteration.jl")
    export hditer, uhditer, flatten_uhditer, flatten_hditer, total_count

    include("Math.jl")
    export ∏, ∑, ≆, ≊
end
