""" Function that goes from Rn -> R1
"""


function addition_merge(args::Array{T, 1}) where T
    sum = 0
    for arg in args
        sum += arg
    end
    sum
end

function multiplication_merge(args::Array{T, 1}) where T
    product = 0
    for arg in args
        product *= arg
    end
    product
end
