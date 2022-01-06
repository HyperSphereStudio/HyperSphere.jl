struct SNumber
    digits::Vector{Float32}
    point::Int16
    base::Float32

    function SNumber(digits::Vector{Float32}, point::Int16; base=10.0, num_digits=10)
        new(digits, point, base)
    end

    function SNumber(v::Number; base::Float64=10.0, num_digits=10)
        if v == 0
            return new([0], 0, base)
        end
        digits = zeros(Float32, num_digits)
        point::Int16 = 0
        start_digit = Int32(floor(log(base, v))) + 1
        point = start_digit - 1

        counter = 1
        for i in start_digit:-1:(start_digit - num_digits + 1)
            b = base ^ (i - point)
            d = v / b
            res = isapprox(d, ceil(d)) ? ceil(d) : floor(d)
            if res > 0
                v -= b * res
                digits[counter] = res
            end
            counter += 1
        end
        SNumber(digits, point, base=base, num_digits=num_digits)
    end

    Base.:+(n::SNumber, i::Number) = n + SNumber(i)
    Base.getindex(n::SNumber, i::Integer) = i > length(n.digits) || i <= 0 ? 0 : n.digits[i]
    digits(n::SNumber) = digits
    Base.length(n::SNumber) = length(n.digits)
    Base.print(io::IO, n::SNumber) = Base.string(n)

    function Base.string(n::SNumber)
        str = ""
        for i in 1:n.point
            str *= i != n.point ? string(n.digits[i]) * ", " : string(n.digits[i])
        end
        str *= ":"
        for i in (n.point + 1):length(n)
                str *= i != length(n) ? string(n.digits[i]) * ", " : string(n.digits[i])
        end
        str * "    Base:" * string(n.base)
    end

    function Base.:+(n::SNumber, n2::SNumber)
        b = max(n.base, n2.base)
        SNumber(basesum(n, b) + basesum(n2, b), base=n.base, num_digits=length(n))
    end

end


function basesum(n::SNumber; base_num::Float64=base)
    sum::Float64 = 0
    for d in 1:length(n)
        sum += n[d] * base_num ^ (d - n.point)
    end
    sum
end
