module Nodes
    import ...Activation
    import ..Functional
    using ...Utils
    using ...Functions

    @Fun(Func{T}, T, constants::APtr{T}, arg::T)

    export Node

    struct Node{T} <: AbstractMathFun{T, 1}
        merge::Functional.Func{T}
        fun::Func{T}
        activation::Activation.Func{T}
        constant_size::UInt16

        Node{T}(merge::Functional.Func{T}, fun::Func{T}, activation::Activation.Func{T}, constant_size) where {T} = new{T}(merge, fun, activation, UInt16(constant_size))

        (node::Node{T})(constants::APtr{T}, args::AbstractArray{T}) where {T} = node.activation(node.fun(constants, node.merge(args)))
    end

    LinearNode(T::Type; merge_function = :summation, activation_function = :Tanh) = 
        Node{T}(findOrIsMethod(Functional, merge_function)(T),
                Func{T}((constants, arg) -> constants[1] * arg + constants[2]),
                findOrIsMethod(Activation, activation_function)(T),
                2)

    
end



