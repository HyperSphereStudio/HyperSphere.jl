module CommonStaticFunctions

    module Single
        using Base.MathConstants
        import ....@Fun

        @Fun(Func{InputType, OutputType}, OutputType, arg::InputType)

        export Sin, Cos, Tan, ASin, ACos, ATan, Tanh
        Sin(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(sin(x)))
        Cos(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(cos(x)))
        Tan(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(tan(x)))
        ASin(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(asin(x)))
        ACos(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(acos(x)))
        ATan(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(atan(x)))
        Tanh(IT::Type, OT::Type) = Func{IT, OT}(x -> OT((e ^ x - e ^ -x) / (e ^ x + e ^ -x)))

        export RMax, RMin, LMax, LMin,Sigmoid
        RMax(IT::Type, OT::Type, Lower_Bound) = Func{IT, OT}(x -> OT(max(Lower_Bound, x)))
        RMin(IT::Type, OT::Type, Lower_Bound) = Func{IT, OT}(x -> OT(min(Lower_Bound, x)))
        LMax(IT::Type, OT::Type, Upper_Bound) = Func{IT, OT}(x -> OT(max(x, Upper_Bound)))
        LMin(IT::Type, OT::Type, Upper_Bound) = Func{IT, OT}(x -> OT(min(x, Upper_Bound)))
        Sigmoid(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(1 / (1 + e ^ -x)))

        export Linear, Quadratic, Cubic, Sqrt
        Linear(IT::Type, OT::Type, slope, constant) = Func{IT, OT}(x -> OT(slope * x + constant))
        Quadratic(IT::Type, OT::Type, a, b, c) = Func{IT, OT}(x -> OT(a * x ^ 2 + b * x + c))
        Cubic(IT::Type, OT::Type, a, b, c, d) = Func{IT, OT}(x -> OT(a * x ^ 3 + b * x ^ 2 + c * x + d))
        Sqrt(IT::Type, OT::Type) = Func{IT, OT}(x -> OT(sqrt(x)))


        export LeftValuePieceWise, RightValuePieceWise
        function LeftValuePieceWise(IT::Type, OT::Type, functions::AbstractArray{Func}, values)
            sort!(values)
            return Func{IT, OT}(function (x)
                    i = 1
                    while i < length(values) && x < values[i]
                        i += 1
                    end
                    OT(functions[i](x))
                end)
        end
    
        function RightValuePieceWise(IT::Type, OT::Type, functions::AbstractArray{Func}, values)
            sort!(values)
            return Func{IT, OT}(function (x)
                    i = length(slopes)
                    while i > 1 && x > values[i]
                        i -= 1
                    end
                    OT(functions[i](x))
                end)
        end

    end
end
