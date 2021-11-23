include("../HyperSphere.jl")
import .HyperSphere

num = 6197 * 7919
@time println("", "Result Analytic:", HyperSphere.next_factor(num))
@time println("", "Result Brute Force:", HyperSphere.brute_next_factor(num))
