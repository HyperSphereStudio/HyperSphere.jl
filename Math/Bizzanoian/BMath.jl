module BMath
    include("BPoint.jl")
    include("BPlot.jl")
end

using Main.BMath
using Main.BMath.BPlot

sets = []
xvals = []

for x in 1.0:1000.0
    push!(xvals, x)
    push!(sets, BPoint(x, [0.0]) + BPoint(x, [pi/2]))
end

plotb(xvals, sets)
