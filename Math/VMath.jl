export vnorm, vmathlen, gradient, gradient_descent

function vnorm(values::AbstractArray{T}; norm_type=2) where T
    if length(values) == 1; return [1]; end
    len = vmathlen(values, norm_type=norm_type)
    for i in 1:length(values)
        values[i] /= len
    end
    values
end

function vmathlen(values::AbstractArray{T}; norm_type=2) where T
    sum::T = 0
    for v in values
        sum += v ^ norm_type
    end
    sum ^ (1 / norm_type)
end

function gradient(f::Function, values::AbstractArray{T}, gradient_vector::AbstractArray{T}; delta=.0001) where T
    for i in 1:length(values)
        first = f(values)
        values[i] += delta
        gradient_vector[i] = (f(values) - first) / delta
        values[i] -= delta
    end
    gradient_vector
end
