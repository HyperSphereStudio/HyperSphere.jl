module BPlot
    export plotb

    using PyPlot
    import Main.BMath


    function plotb(points::Vector; precision=10, Title="Math Plot", xlbl="X", ylbl="Y")
        xvals = Float64[]
        yvals = Float64[]
        for point in points
            if BMath.dim_count(point) != 1
                error("Cannot Plot Due to way to many dimensions! Needs to be 1")
            end
            c = BMath.cartesian(point)
            push!(xvals, round(c[1], digits=precision))
            push!(yvals, round(c[2], digits=precision))
        end

        pygui(true)
        scatter(xvals, yvals, 1)
        title(Title)
        xlabel(xlbl)
        ylabel(ylbl)
    end

    function plotb(inputs::Vector, points::Vector; precision=10, Title="Math Plot", xlbl="Variable", ylbl="X_Comp", zlbl="Y_Comp")
        xvals = Float64[]
        yvals = Float64[]
        zvals = Float64[]
        for i in 1:length(points)
            point = points[i]
            if BMath.dim_count(point) != 1
                error("Cannot Plot Due to way to many dimensions! Needs to be 1")
            end
            c = BMath.cartesian(point)
            push!(xvals, round(inputs[i], digits=precision))
            push!(yvals, round(c[1], digits=precision))
            push!(zvals, round(c[2], digits=precision))
        end

        pygui(true)
        using3D()
        fig = plt.figure()
        ax = fig.add_subplot(projection="3d")
        ax.set_title(Title)
        ax.set_xlabel(xlbl)
        ax.set_ylabel(ylbl)
        ax.set_zlabel(zlbl)
        ax.scatter(xvals, yvals, zvals, s=1)
    end
end
