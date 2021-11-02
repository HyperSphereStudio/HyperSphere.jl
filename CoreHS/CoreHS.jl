module CoreHS
    abstract type AbstractHSObject end
    struct InternalAbstractClass

    end
    internal_dictionary = Dict{Type, InternalAbstractClass}()

    Base.show(buffer::IO, x::AbstractHSObject) = print(buffer, string(x))
    
    macro abstract_class(type)
        return esc(:(internal_dictionary[$type] = InternalAbstractClass($type)))
    end

    function issupertype(type, check)::Bool
        while type != Any
            if type == check; return true; end
            type = supertype(type)
        end
        return false
    end

    export AbstractHSObject, InternalAbstractClass, internal_dictionary
    export issupertype, @abstract_class
end
