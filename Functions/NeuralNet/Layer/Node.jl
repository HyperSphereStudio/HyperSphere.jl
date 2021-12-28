module Nodes
    import ...Activation
    import ..Functional
    using ...Utils
    using ...Functions

    @Fun(Func{ST, IT, OT}, OT, constants::APtr{ST}, arg::IT)
    @Fun(Wrapper, Func, StorageType::Type, InputType::Type, OutputType::Type)

    export Node, LinearNode

    struct Node{ST, IT, OT} <: AbstractMathFun{IT, 1}
        merge::Functional.Func{IT}
        fun::Func{ST, IT, OT}
        activation::Activation.Func{IT, OT}
        constant_size::UInt16

        Node{ST, IT, OT}(merge::Functional.Wrapper, fun::Func, activation::Activation.Wrapper, constant_size) where {ST, IT, OT} = new{ST, IT, OT}(merge(IT), fun, activation(IT, OT), UInt16(constant_size))

        (node::Node{ST, IT, OT})(constants::APtr{ST}, args::Array{IT, 1}) where {ST, IT, OT} = node.activation(node.fun(constants, node.merge(args)))
    end

    LinearNode(; functional::Functional.Wrapper = Functional.None(), activation::Activation.Wrapper = Activation.None()) = 
       return Wrapper((ST, IT, OT) -> 
                        (Node{ST, IT, OT}(functional,
                            Func{ST, IT, OT}((constants, arg) -> constants[1] * arg + constants[2]),
                            activation,
                            2)))

end



