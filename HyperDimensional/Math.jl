≆(x, p) = !isapprox(x, p)
≊(x, p) = isapprox(x, p)

function ∏(v::AbstractVector{T}) where T
    product = 1
    for i in v
        product *= i
    end
    product
end

function ∏(args...)
    product = 1
    for i in args
        product *= i
    end
    product
end

function ∑(args...)
    sum = 0
    for i in args
        sum += i
    end
    sum
end

function ∑(v::AbstractVector{T}) where T
    sum = 0
    for i in args
        sum += i
    end
    sum
end
