module Nodes
    import ...Activation
    import ..Functional
    using ...Utils
    using ...Functions

    @Fun(Func{ST, IT, OT}, OT, constants::APtr{ST}, arg::IT)
    @Fun(Wrapper, Func, StorageType::Type, InputType::Type, OutputType::Type)

    export Node, LinearNode, VarPolyNode, QuadraticNode, PolyNode, VarRationalNode

    struct Node{ST, IT, OT} <: AbstractMathFun{IT, 1}
        merge::Functional.Func{IT}
        fun::Func{ST, IT, OT}
        activation::Activation.Func{IT, OT}
        constant_size::UInt16

        Node{ST, IT, OT}(merge::Functional.Wrapper, fun::Func, activation::Activation.Wrapper, constant_size) where {ST, IT, OT} = new{ST, IT, OT}(merge(IT), fun, activation(IT, OT), UInt16(constant_size))

        (node::Node{ST, IT, OT})(constants::APtr{ST}, args::Array{IT, 1}) where {ST, IT, OT} = node.activation(node.fun(constants, node.merge(args)))
    end

    function calc_poly(IT, OT, powers, arg, constants; cons_offset = 0)
        sum::IT = 0
        i = 1
        if arg < 0
            arg *= -1
            for pow in powers
                sum += constants[i + cons_offset] * arg ^ pow
                i -= 1
            end
        else
            for pow in powers
                sum += constants[i + cons_offset] * arg ^ pow
                i += 1
            end
        end
        OT(sum)
    end

    function calc_var_poly(IT, OT, power_len, arg, constants; cons_offset = 0)
        sum::IT = 0
        if arg < 0
            arg *= -1
            for i in 1:power_len
                sum -= constants[i + cons_offset] * arg ^ constants[i + cons_offset + power_len]
            end
        else
            for i in 1:power_len
                sum += constants[i + cons_offset] * arg ^ constants[i + cons_offset + power_len]
            end
        end
        OT(sum)
    end

    LinearNode(; functional::Functional.Wrapper = Functional.None(), activation::Activation.Wrapper = Activation.None())  = PolyNode(powers=0:1, functional=functional, activation=activation)  
    QuadraticNode(; functional::Functional.Wrapper = Functional.None(), activation::Activation.Wrapper = Activation.None()) = PolyNode(powers=0:2, functional=functional, activation=activation)       

    PolyNode(; powers = 0:2, functional::Functional.Wrapper = Functional.None(), activation::Activation.Wrapper = Activation.None()) = 
       return Wrapper((ST, IT, OT) -> Node{ST, IT, OT}(
                            functional,
                            Func{ST, IT, OT}((constants, arg) -> calc_poly(IT, OT, powers, arg, constants)),
                            activation,
                            length(powers)))              

    RationalNode(; num_powers = 0:2, denom_powers = 0:2, functional::Functional.Wrapper = Functional.None(), activation::Activation.Wrapper = Activation.None()) = 
       return Wrapper((ST, IT, OT) -> Node{ST, IT, OT}(
                            functional,
                            Func{ST, IT, OT}((constants, arg) -> calc_poly(IT, OT, num_powers, arg, constants) / calc_poly(IT, OT, denom_powers, arg, constants; cons_offset = length(num_powers))),
                            activation,
                            length(num_powers) + length(denom_powers)))

    VarPolyNode(; num_terms::Int = 2, functional::Functional.Wrapper = Functional.None(), activation::Activation.Wrapper = Activation.None()) = 
       return Wrapper((ST, IT, OT) -> Node{ST, IT, OT}(
                            functional,
                            Func{ST, IT, OT}((constants, arg) -> calc_var_poly(IT, OT, num_terms, arg, constants)),
                            activation,
                            num_terms * 2))                

    VarRationalNode(; num_terms::Int = 2, denom_terms::Int = 2, functional::Functional.Wrapper = Functional.None(), activation::Activation.Wrapper = Activation.None()) = 
       return Wrapper((ST, IT, OT) -> Node{ST, IT, OT}(
                            functional,
                            Func{ST, IT, OT}((constants, arg) -> calc_var_poly(IT, OT, num_terms, arg, constants) / calc_var_poly(IT, OT, denom_terms, arg, constants; cons_offset = 2 * num_terms)),
                            activation,
                            2 * (num_terms + denom_terms)))        
                            
    
end



