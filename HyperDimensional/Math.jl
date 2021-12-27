export ∏, ∑, ≆, ≊

≆(x, p) = !isapprox(x, p)
≊(x, p) = isapprox(x, p)



function ∏(v::AbstractVector; T=Float64)
    product::T = 1.0
    for i in v
        product *= i
    end
    product
end

function ∏(args...; T=Float64)
    product::T = 1.0
    for i in args
        product *= i
    end
    product
end

function ∑(args...; T=Float64)
    sum::T = 0.0
    for i in args
        sum += i
    end
    sum
end

function ∑(v::AbstractVector; T=Float64)
    sum::T = 0.0
    for i in args
        sum += i
    end
    sum
end
