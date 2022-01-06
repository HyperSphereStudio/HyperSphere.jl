#Written By Johnathan Bizzano
module CommonStaticFunctions

    module Single
        using Base.MathConstants
        import ....@Fun

        export Sin, Cos, Tan, ASin, ACos, ATan, Tanh

        Wrap(sig::Signature, f::Function) = MemoryWrapper(
            sig,
            function (sett)
                IT = sett.inputType
                return arg -> IT(f(arg))
            end
        )

        Sin() = Wrap(Sig(:Sin), sin)
        Cos() = Wrap(Sig(:Cos), cos)
        Tan() = Wrap(Sig(:Tan), tan)
        ASin() = Wrap(Sig(:ASin), asin)
        ACos() = Wrap(Sig(:ACos), acos)
        ATan() = Wrap(Sig(:ATan), atan)
        Tanh() = Wrap(Sig(:Tanh), x -> (e ^ x - e ^ -x) / (e ^ x + e ^ -x))

        export RMax, RMin, LMax, LMin,Sigmoid
        RMax(Lower_Bound) = Wrap(Sig(:RMax), x -> max(Lower_Bound, x))
        RMin(Lower_Bound) = Wrap(Sig(:RMin), x -> min(Lower_Bound, x))
        LMax(Upper_Bound) = Wrap(Sig(:LMax), x -> max(x, Upper_Bound))
        LMin(Upper_Bound) = Wrap(Sig(:LMin), x -> min(x, Upper_Bound))
        Sigmoid() = Wrap(Sig(:Sigmoid), x -> 1 / (1 + e ^ -x))

        export Linear, Quadratic, Cubic, Sqrt
        Add(constant) = Wrap(Sig(:Add), x -> x + constant)
        Multiply(constant) = Wrap(Sig(:Multiply), x -> x * constant)
        Linear(slope, constant) = Wrap(Sig(:Linear), x -> slope * x + constant)
        Quadratic(a, b, c) = Wrap(Sig(:Quadratic), x -> a * x ^ 2 + b * x + c)
        Cubic(a, b, c, d) = Wrap(Sig(:Cubic), x -> a * x ^ 3 + b * x ^ 2 + c * x + d)
        Sqrt() = Wrap(Sig(:Sqrt), sqrt)


        export LeftValuePieceWise, RightValuePieceWise
        function LeftValuePieceWise(functions::AbstractArray{Func}, values)
            sort!(values)
            return Wrap(
                Sig(:LeftValuePieceWise),
                function (x)
                    i = 1
                    while i < length(values) && x < values[i]
                        i += 1
                    end
                    functions[i](x)
                end)
        end
    
        function RightValuePieceWise(functions::AbstractArray{Func}, values)
            sort!(values)
            return Wrap(
                Sig(:RightValuePieceWise), 
                    function (x)
                        i = length(slopes)
                        while i > 1 && x > values[i]
                            i -= 1
                        end
                        functions[i](x)
                    end)
        end

    end
end
