export SumFunction

struct SumFunction{T, N} <: AbstractMathFun{T, N} 
    terms::MFCollection

    SumFunction{T, N}() where {T, N} = new{T, N}(MFCollection(undef, 0))
    SumFunction{T, N}(terms::MFCollection) where {T, N} = new{T, N}(terms)

    Base.insert!(p::SumFunction, i::Integer, term::AbstractMathFun) = insert!(p.terms, i, term)
    Base.push!(p::SumFunction, term::AbstractMathFun) = push!(p.terms, term)
    Base.deleteat!(p::SumFunction, range) = deleteat!(p.terms, range)
    Base.length(p::SumFunction) = length(p.terms)
    Base.getindex(p::SumFunction, i::Integer) = getindex(p.terms, i)
    Base.setindex!(p::SumFunction, val::AbstractMathFun, i::Integer) = setindex!(p.terms, val, i)
    Base.iterate(p::SumFunction) = Base.iterate(p.terms)
    Base.iterate(p::SumFunction, state) = Base.iterate(p.terms, state)
    
    function Functions.string(p::SumFunction, emitter::FunctionEmitter)
        str = "∑("
        first_print = true
        for term in p.terms
            term_str = string(term, emitter)
            length(term_str) != 0 && (str *= (first_print ? term_str : ", " * term_str); first_print = false)
        end
        str * ")"
    end

    function (p::SumFunction)(call::MFCall)
        Sum = 0.0
        for term in p.terms
            Sum += term(call)
        end
        call(Sum)
    end

    function Functions.emit(f::SumFunction{T, N}, emitter::FunctionEmitter{T}) where {T, N}
        sum_expr = Expr(:call, :∑)
        for term in f.terms
            push!(sum_expr.args, emit(term, emitter))
        end
        push!(sum_expr.args, Expr(:kw, :T, Symbol(string(T))))
        sum_expr
    end

    function Functions.simplify(f::SumFunction{T, N}, emit_constants::Bool) where {T, N}
        constsum = 0
        termcpy = MFCollection(undef, 0)

        for item in f.terms
            item = simplify(item, emit_constants)
            if is_constant(item, emit_constants)
                constsum += item.value
            else
                if item isa SumFunction
                    append!(termcpy, item.terms)
                else
                    push!(termcpy, item)
                end
            end
        end

        (constsum != 0) && push!(termcpy,  ConstFunction{T}(constsum))
        (length(termcpy) == 0) && return ConstFunction{T}(constsum)
        length(termcpy) == 1 && return termcpy[1]
        return SumFunction{T, N}(termcpy)
    end
end