function odd_iter_count(iteration, x, value)
    return floor(log(6, (value * 2 ^ iteration) / (x)))
end

function sum_array(arr, start_i, end_i)::Float64
    sum::Float64 = 0.0
    for i in start_i:end_i
        sum += arr[i]
    end
    sum
end

function collatz(x)
    if x % 2 == 0
        return x / 2
    end
    return 3 * x + 1
end

function collatz_conj(x)
    n_set = [0]
    even_count = 0
    odd_count = 0
    iteration = 0
    while x != 1
        if x % 2 == 0
            even_count += 1
            n_set[end] += 1
        else
            append!(n_set, 0)
            odd_count += 1
        end
        x = collatz(x)
        iteration += 1
    end

    (reverse!(n_set), iteration, even_count, odd_count)
end

function inverse_collatz_conj(n; Type=Float64)
    f = length(n)
    inner_sum::Float64 = 0
    for i in 2:f
        inner_sum += (2 ^ sum_array(n, i, f - 1)) * 3 ^ (i - 2)
    end
    end_ratio::Type = ((2 ^ n[end]) / (3 ^ (f - 1)))
    return round(end_ratio * (2 ^ sum_array(n, 1, f - 1) - inner_sum))
end

g(x) = (x-1)/3
z(x, m) = m * g(x)

function apply(f, x, m, n=1)
    for _ in 1:n
        x = f(x, m)
    end
    return x
end


function collect_collatz(size)
    xvals = zeros(Float64, size)
    yvals = zeros(Float64, size)

    for idx in 1:size
        i = 2 * idx - 1
        n = collatz_conj(i)[1]
        f = length(n)
        pow = sum_array(n, 1, f - 1)

        xvals[idx] = idx
        yvals[idx] = pow
    end
    (xvals, yvals)
end
