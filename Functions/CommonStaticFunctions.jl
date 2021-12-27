module CommonStaticFunctions

    module Single
        using Base.MathConstants
        import ....@Fun

        @Fun(Func{T}, T, arg::T)

        export Sin, Cos, Tan, ASin, ACos, ATan, Tanh
        Sin(T::Type) = Func{T}(x -> T(sin(x)))
        Cos(T::Type) = Func{T}(x -> T(cos(x)))
        Tan(T::Type) = Func{T}(x -> T(tan(x)))
        ASin(T::Type) = Func{T}(x -> T(asin(x)))
        ACos(T::Type) = Func{T}(x -> T(acos(x)))
        ATan(T::Type) = Func{T}(x -> T(atan(x)))
        Tanh(T::Type) = Func{T}(x -> T((e ^ x - e ^ -x) / (e ^ x + e ^ -x)))

        export RMax, RMin, LMax, LMin,Sigmoid
        RMax(T::Type, Lower_Bound) = Func{T}(x -> T(max(Lower_Bound, x)))
        RMin(T::Type, Lower_Bound) = Func{T}(x -> T(min(Lower_Bound, x)))
        LMax(T::Type, Upper_Bound) = Func{T}(x -> T(max(x, Upper_Bound)))
        LMin(T::Type, Upper_Bound) = Func{T}(x -> T(min(x, Upper_Bound)))
        Sigmoid(T::Type) = Func{T}(x -> T(1 / (1 + e ^ -x)))

        export Linear, Quadratic, Cubic, Sqrt
        Linear(T::Type, slope, constant) = Func{T}(x -> slope * x + constant)
        Quadratic(T::Type, a, b, c) = Func{T}(x -> T(a * x ^ 2 + b * x + c))
        Cubic(T::Type, a, b, c, d) = Func{T}(x -> T(a * x ^ 3 + b * x ^ 2 + c * x + d))
        Sqrt(T::Type) = Func{T}(x -> T(sqrt(x)))


        export LeftValuePieceWise, RightValuePieceWise
        function LeftValuePieceWise(functions::AbstractArray{Func{T}}, values) where T
            sort!(values)
            Func{T}(
                function (x)
                    i = 1
                    while i < length(values) && x < values[i]
                        i += 1
                    end
                    functions[i](x)
                end)
        end
    
        function RightValuePieceWise(functions::AbstractArray{Func{T}}, values) where T
            sort!(values)
            Func{T}(
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
