module NeuralNet
    import Main.HyperSphere.Functions
    using BlackBoxOptim

    abstract type AbstractNeuralNet{Data_Type} <: Functions.AbstractMathmaticalFunction{Data_Type} end
    export AbstractNeuralNet, simple_constant_solver, wrapsolver

    include("Layer.jl")
    include("ErrorFunctions.jl")
    include("Optimizers.jl")
    include("Gen3Net.jl")


    """Solve for the best constants that fit f
       f(constants, x)::Number
    """
    function simple_constant_solver(x_values, y_values, f::Function; SearchRange = (-50.0, 50.0), NumDimensions=1)
        best_candidate(
            bboptimize(constants -> meanabserr(x_values, y_values, wrapsolver(constants, f)), TraceMode = :silent, SearchRange = SearchRange, NumDimensions = NumDimensions))
    end

    """
        Wrap constants into single input function
    """
    wrapsolver(constants, f::Function) = x -> f(constants, x)
end
