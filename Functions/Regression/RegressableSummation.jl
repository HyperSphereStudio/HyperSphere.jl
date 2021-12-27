export RegressableSummation, RegressableSummationTrainer

using LinearAlgebra
using ...Functions

const TermsArray{T, N} = Array{ProductFunction{T, N}, 1}

struct RegressableSummation{T, N}  <: AbstractMathFun{T, N}
    sum_function::AbstractMathFun{T, N}
    coefficients::Array{T, 1}

    #For Training
    terms::SumFunction{T, N}

    RegressableSummation{T, N}(sum_function::AbstractMathFun{T, N}, coefficients::Array{T, 1}, terms::SumFunction{T, N}) where {T, N} = new{T, N}(sum_function, coefficients, terms)

    RegressableSummation{T, N}(term_functions::TermsArray{T, N}) where {T, N} = RegressableSummation{T, N}(term_functions, zeros(T, length(term_functions)))
    
    function RegressableSummation{T, N}(term_functions::TermsArray{T, N}, coefficients::Array{T}) where {T, N}
        terms = Array{AbstractMathFun, 1}(undef, length(term_functions))
        #Put a constant coefficient term in front of all products
        for i in 1:length(term_functions)
            constant = ConstFunction{T}(1.0, force_emit = false)
            insert!(term_functions[i], 1, constant)
            terms[i] = term_functions[i]
        end

        #Create a summation function
        sum_function = SumFunction{T, N}(terms)

        #Compile the summation function to machine code and return math function
        new{T, N}(emit(sum_function, :RegressableSummationGeneration, EmitConstants = false), coefficients, sum_function)
    end

    (f::RegressableSummation{T, N})(call::MFCall) where {T, N} = call(f.sum_function(call.args, f.coefficients))

    Base.length(x::RegressableSummation) = Base.length(x.terms)

    function Base.string(x::RegressableSummation{T, N}) where {T, N}
        return functionheader(x, N) * Functions.string(x.terms, false) * "\nCoefficients:" * string(x.coefficients)
    end
end

Functions.simplify(x::RegressableSummation{T, N}) where {T, N} = RegressableSummation{T, N}(x.sum_function, x.coefficients, simplify(x.terms, false))

struct RegressableSummationTrainer{T, N} <: AbstractTrainer{T, N}
    f::RegressableSummation{T, N}
    trainableSVDMatrix::Matrix{T}
    trainableOutputs::Array{T}
    precision::UInt8

    function RegressableSummationTrainer{T, N}(f::RegressableSummation{T, N}; precision=10) where {T, N}
        RegressableSummationTrainer{T, N}(f, zeros(T, length(f), length(f)), zeros(T, length(f)), precision=precision)
    end

    function RegressableSummationTrainer{T, N}(f::RegressableSummation{T, N}, trainableSVDMatrix::Matrix{T}, trainableOutputs::AbstractArray{T}; precision=10) where {T, N}
        new{T, N}(f, trainableSVDMatrix, trainableOutputs, precision)
    end

    Base.sizeof(x::RegressableSummationTrainer{T, N}) where {T, N} = sizeof(RegressableSummationTrainer{T, N}) + sizeof(x.f) + sizeof(x.trainableOutputs) + sizeof(x.trainableSVDMatrix)

    Base.string(x::RegressableSummationTrainer) = string(x.f) * "\nMemory Size:" * string(sizeof(x)) * " Bytes\n"
end

function Functions.train!(f::RegressableSummationTrainer{T, N}, data::AbstractDataSet{T, N}; Data_Type::Type=T) where {T, N}
    length(data) == 0 && return

    for row in 1:length(f.f)
        for col in 1:length(f.f)

            #Only calculate upper trianglar matrix and transpose
            col >= row || continue
            product_sum = f.trainableSVDMatrix[row, col]
            row == 1 && (output_product_sum = f.trainableOutputs[col])

            #Calculate the element product of every function upon every product combination of terms
            for data_entry_index in 1:length(data)
                inputs = data[data_entry_index].inputs
                product::T = f.f.terms[row](inputs, Data_Type = Data_Type) * f.f.terms[col](inputs, Data_Type = Data_Type)
                product_sum += product
                row == 1 && (output_product_sum += data[data_entry_index].outputs[1] * product)
            end

            #Singular Transpose
            f.trainableSVDMatrix[row, col] = product_sum
            f.trainableSVDMatrix[col, row] = product_sum

            row == 1 && (f.trainableOutputs[col] = output_product_sum)
        end
    end

    #Perform Min Normalization to solve AX+B=Y for A
    #Copy the results to the function coefficients
    copy!(f.f.coefficients, round.(LAPACK.gesv!(copy(f.trainableSVDMatrix), copy(f.trainableOutputs))[1], digits=f.precision))
end
