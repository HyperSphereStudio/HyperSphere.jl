module BMath
    include("BPoint.jl")
    include("BPlot.jl")
end


import Main.BMath
include("BPlot.jl")
using Main.BPlot

points = []
xvals = []

for x in -1000:.5:1000.0
    push!(xvals, x)
    push!(points, BMath.cross(BMath.BPoint(x, pi/2), BMath.BPoint(x, 0)))
end

BPlot.plotb(xvals, points)
