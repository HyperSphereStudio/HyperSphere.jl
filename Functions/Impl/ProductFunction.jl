export ProductFunction



struct ProductFunction{T, N} <: AbstractMathFun{T, N} 
    terms::MFCollection

    ProductFunction{T, N}() where {T, N} = new{T, N}(MFCollection(undef, 0))
    ProductFunction{T, N}(terms::MFCollection) where {T, N} = new{T, N}(terms)

    Base.insert!(p::ProductFunction, i::Integer, term::AbstractMathFun) = insert!(p.terms, i, term)
    Base.push!(p::ProductFunction, term::AbstractMathFun) = push!(p.terms, term)
    Base.deleteat!(p::ProductFunction, range) = deleteat!(p.terms, range)
    Base.length(p::ProductFunction) = length(p.terms)
    Base.getindex(p::ProductFunction, i::Integer) = getindex(p.terms, i)
    Base.setindex!(p::ProductFunction, val::AbstractMathFun, i::Integer) = setindex!(p.terms, val, i)
    Base.iterate(p::ProductFunction) = Base.iterate(p.terms)
    Base.iterate(p::ProductFunction, state) = Base.iterate(p.terms, state)

    function Functions.string(p::ProductFunction, emitter::FunctionEmitter)
        str = "∏("
        first_print = true
        for term in p.terms
            term_str = string(term, emitter)
            length(term_str) != 0 && (str *= (first_print ? term_str : ", " * term_str); first_print = false)
        end
        str * ")"
    end
    
    function (p::ProductFunction)(call::MFCall)
        product = 1.0
        for term in p.terms
            product *= term(call::MFCall)
        end
        call(product)
    end

    function Functions.emit(f::ProductFunction{T, N}, emitter::FunctionEmitter{T}) where {T, N}
        prod_expr = Expr(:call, :∏)
        for term in f.terms
            push!(prod_expr.args, emit(term, emitter))
        end
        push!(prod_expr.args, Expr(:kw, :T, Symbol(string(T))))
        prod_expr
    end

    function Functions.simplify(f::ProductFunction{T, N}, emit_constants::Bool) where {T, N}
        constprod = 1
        termcpy = MFCollection(undef, 0)

        for item in f.terms
            item = simplify(item, emit_constants)
            if is_constant(item, emit_constants)
                constprod *= item.value
            else
                if item isa ProductFunction
                    append!(termcpy, item.terms)
                else
                    push!(termcpy, item)
                end
            end
        end
        
        (constprod != 1 && constprod != 0) && push!(termcpy,  ConstFunction{T}(constprod))
        (length(termcpy) == 0) && return ConstFunction{T}(constprod)
        length(termcpy) == 1 && return termcpy[1]
        return ProductFunction{T, N}(termcpy)
    end
end