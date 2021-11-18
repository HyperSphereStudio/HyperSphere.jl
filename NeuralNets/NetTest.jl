include("../HyperSphere.jl")
import .HyperSphere


f(x) = 2 * x ^ 2 + 3.4x

function errorf(c)
    sum = 0.0
    for i in 1:1000
        sum += abs(f(i) - (c[1] * i ^ 2 + c[2] * i))
    end
    sum / 1000
end



println(HyperSphere.optimize(errorf, (-10.0, 10.0), 2))
