export @class, @mclass, @mbclass, @bclass


"""Has mutable non inherititing super class"""
macro mbclass(class_info::Expr, body::Expr)
    gen_class(true, false, class_info, body)
end

"""Has non inherititing super class"""
macro bclass(class_info::Expr, body::Expr)
    gen_class(false, false, class_info, body)
end

"""Has mutable inherititing super class"""
macro mclass(class_info::Expr, body::Expr)
    gen_class(true, true, class_info, body)
end

"""Has inherititing super class"""
macro class(class_info::Expr, body::Expr)
    gen_class(false, true, class_info, body)
end

"""No Super Class. Is mutable"""
macro mclass(name::Symbol, body::Expr)
    gen_class(true, false, name, body)
end

"""No Super Class"""
macro class(name::Symbol, body::Expr)
    gen_class(false, false, name, body)
end

macro print_tree(expr::Expr)
    _print_tree(expr, 0)
end

function _print_tree(expr::Expr, level::Int64)
    println(repeat("\t", level), expr.head)
    for item in expr.args
        if item isa Expr
            _print_tree(item, level + 1)
        else
            println(repeat("\t", level + 1), item)
        end
    end
end


function search_expr(expr::Expr, sym::Symbol)
    if expr.head == sym
        return expr
    end
    for i in 1:length(expr.args)
        item = expr.args[i]
        if item isa Expr
            if item.head == sym
                return (parent, i)
            end
            return search_expr(item, sym)
        elseif item isa Symbol
            if item == sym
                return (expr, i)
            end
        end
    end
    return nothing
end

function search_expr_sym(expr::Expr; allowLineNumber::Bool=false)
    for i in 1:length(expr.args)
        item = expr.args[i]
        if item isa Expr
            return search_expr_sym(item)
        elseif !(item isa LineNumberNode) || allowLineNumber
            return (expr, i)
        end
    end
    return nothing
end

function gen_class(is_mut::Bool, inherit_super_class::Bool, class_info, body::Expr)
    structExpr::Expr = Expr(:struct, is_mut)
    expr::Expr = Expr(:block, structExpr)
    aclazz = nothing
    sclazz = nothing

    if class_info isa Symbol
        aclazz = Symbol("Abstract" * string(class_info))
        insert!(expr.args, 1, esc(:(abstract type $aclazz end)))
    else
        aclazz_parent_expr::Expr = class_info
        aclazz_sym_idx::Int64 = 1

        if class_info.args[1] isa Expr
            aclazz_res = search_expr_sym(class_info.args[1])
            aclazz_parent_expr = aclazz_res[1]
            aclazz_sym_idx = aclazz_res[2]
        end

        aclazz_parent_expr.args[aclazz_sym_idx] = Symbol("Abstract" * string(aclazz_parent_expr.args[aclazz_sym_idx]))
        aclazz = class_info.args[1]

        if length(class_info.args) > 1
            sclazz_parent_expr::Expr = class_info
            sclazz_sym_idx::Int64 = 2

            if class_info.args[2] isa Expr
                sclazz_res = search_expr_sym(class_info.args[2])
                sclazz_parent_expr = sclazz_res[1]
                sclazz_sym_idx = sclazz_res[2]
            end

            if inherit_super_class
                sclazz_parent_expr.args[sclazz_sym_idx] = Symbol("Abstract" * string(sclazz_parent_expr.args[sclazz_sym_idx]))
            end

            sclazz = class_info.args[2]

            insert!(expr.args, 1, esc(:(abstract type $aclazz <: $sclazz end)))
        else
            insert!(expr.args, 1, esc(:(abstract type $aclazz end)))
        end

        class_info = class_info.args[1]
    end

    structBlock = Expr(:block)
    push!(structExpr.args, class_info)
    push!(structExpr.args, structBlock)

    if inherit_super_class
        s_type = Meta.eval(esc(:(Type($sclazz))))

        for field in 1:fieldcount(s_type)
            push!(structBlock.args, Expr(::, Symbol(fieldname(s_type, field)), Symbol(fieldtype(s_type, field)))
        end
    end

    _print_tree(expr, 0)
end


abstract type T{C1, C2 <: Real} end

@print_tree begin
    abstract type AbstractT2{C, C1 <: Real} end

    struct T2{C, C1 <: Real} <: AbstractT2{C, C1}
        f::C
        f2::C
    end
end

@class T3{C1, C2 <: Real} <: T{C1, C2} begin

end
