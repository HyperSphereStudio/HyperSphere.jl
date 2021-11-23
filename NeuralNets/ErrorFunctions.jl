export meanabserr, meansqrerr, meanerr

function meanabserr(x_values, y_values, func::Function)
    sum = 0
    for i in 1:length(x_values)
        sum += abs(func(x_values[i]) - y_values[i])
    end
    sum / length(x_values)
end

function meansqrerr(x_values, y_values, func::Function)
    sum = 0
    for i in 1:length(x_values)
        sum += (func(x_values[i]) - y_values[i]) ^ 2
    end
    sqrt(sum) / length(x_values)
end

function meanerr(x_values, y_values, func::Function)
    sum = 0
    for i in 1:length(x_values)
        sum += func(x_values[i]) - y_values[i]
    end
    sum / length(x_values)
end
