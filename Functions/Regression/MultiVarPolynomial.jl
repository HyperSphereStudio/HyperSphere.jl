#Written By Johnathan Bizzano
export MultiVarPolynomial

struct MultiVarPolynomial{T, N} <: AbstractMathFun{T, N}
    summation::RegressableSummation{T, N}

    function MultiVarPolynomial{T, N}(powers::AbstractArray) where {T, N}
        new{T, N}(Functions.RegressableSummation{T, N}(GeneratePowers(powers, T, N)))
    end

    function GeneratePowers(iter::AbstractArray, T::Type, Var_Len)
        iter = adjoint(iter)
        arr = TermsArray{T, Var_Len}(undef, size(iter, 1))
        i = 1
        vars = [Functions.VarFunction{T}(v) for v in 1:Var_Len]
        for row in eachrow(iter)
            powCollection = MFCollection(undef, Var_Len)
            for col in 1:Var_Len
                powCollection[col] = Functions.PowFunction{T, Var_Len}(vars[col], row[col])
            end
            arr[i] = Functions.ProductFunction{T, Var_Len}(powCollection)
            i += 1
        end
        arr
    end

    (f::MultiVarPolynomial{T, N})(args::AbstractArray{T}; Data_Type::Type=T) where {T, N} = f.summation(args, Data_Type = Data_Type)
    Functions.train!(f::MultiVarPolynomial{T, N}, data::AbstractDataSet; Data_Type::Type=T) where {T, N} = Functions.train!(f.summation, data, Data_Type = Data_Type)
    Base.sizeof(x::MultiVarPolynomial) = sizeof(x.summation)
    Base.string(x::MultiVarPolynomial) = string(x.summation)
    Functions.simplify(x::MultiVarPolynomial) = Functions.simplify(x.summation)
    Functions.trainer(f::MultiVarPolynomial{T, N}; precision=10) where {T, N} = RegressableSummationTrainer{T, N}(f.summation, precision = precision)
end

