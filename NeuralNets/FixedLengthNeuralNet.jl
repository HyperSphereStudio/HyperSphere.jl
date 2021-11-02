include("HyperSphere.jl")
import .HyperSphere

f(x) = 500 * x ^ (4/3) + x + 5

row = 3
col = 100
matrix = zeros(row, col)
matrix[1, 1:end] = collect(1.0:1:col)
matrix[2, 1:end] = zeros(col)
matrix[3, 1:end] = zeros(col)
outputs = [Float64(f(i)) for i in 1:col]
poly = HyperSphere.MultiVarPolynomial(matrix, outputs, 4, 2.0, precision=5, trainableMode=true)
HyperSphere.train(poly, matrix, outputs)
println("Test:", poly, "\nf(1):", poly(2.0, 0.0, 0.0), " Real:", f(2))
