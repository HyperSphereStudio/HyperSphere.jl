export AbstractCallable, Fun

abstract type AbstractCallable{R, A <: Tuple} end

struct Fun{R, A <: Tuple} <: AbstractCallable{R, A}
    _function::Function

    function Fun{R, A}(_function::Function) where R where A <: Tuple
        new{R, A}(_function)
    end

    function (f::Fun{R, A})(args...)::R  where R where A <: Tuple
        f._function(args)
    end
end
