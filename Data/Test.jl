macro my_macro()
    for i in (:+, :-, :/, :*)
        name = Symbol("Fun_" * string(i))
        eval(esc(:(
            function $name(arg1, arg2)
                $i(arg1, arg2)
            end)))
    end
end

@my_macro