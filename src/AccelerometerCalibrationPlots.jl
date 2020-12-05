"""
# AccelerometerCalibrationPlots.jl

Debug plots for
[AccelerometerCalibration.jl](../AccelerometerCalibration.jl).
"""
module AccelerometerCalibrationPlots

using AccelerometerCalibration
using Plots

offset_series = []
scale_series = []
rotation_series = []

function reset()
    empty!(offset_series)
    empty!(scale_series)
    empty!(rotation_series)
end

macro circle_plot(x, y)
    quote
        plot( x->sqrt(1 - x^2), color=:black, legend=false);
        plot!(x->-sqrt(1 - x^2), color=:black, legend=false);
        scatter!($(esc(x)),
                 $(esc(y)),
                 xaxis=(label=$(string(x))),
                 yaxis=(label=$(string(y))),
                 xlims=(-1.5,1.5),
                 ylims=(-1.5,1.5),
                 legend=false)
    end
end

macro series_plot(x)
    quote
        plot($(esc(x)), legend=false, xaxis=(label=$(string(x))))
    end
end

function calplot(x, y, z, xc, yc, zc,
                 offset, scale, rotation)
     plot(@circle_plot(x, y), @circle_plot(xc, yc), @series_plot(offset),
          @circle_plot(x, z), @circle_plot(xc, zc), @series_plot(scale),
          @circle_plot(y, z), @circle_plot(yc, zc), @series_plot(rotation),
          layout = (3,3), size=(1200,1200))
end

function calplot(c::AbstractArray{AccelerometerCalibration.Calibration})

    c_count = length(c)
    l = length(c[1].points)

    xyz = [[sc.points[j][i] for i in 1:3, j in 1:l] for sc in c]
    xyzc =[sc.rotation * ((xyz[i] .* sc.scale) .- sc.offset)
           for (i, sc) in enumerate(c)]

    x, y, z = (hcat((xyz[i][j,:] for i in 1:c_count)...) for j in 1:3)
    xc, yc, zc = (hcat((xyzc[i][j,:] for i in 1:c_count)...) for j in 1:3)

    push!(offset_series, vec([c[j].offset[i] for i in 1:3, j in 1:c_count]))
    push!(scale_series, vec([c[j].scale[i] for i in 1:3, j in 1:c_count]))
    push!(rotation_series, vcat([[r.theta1, r.theta2, r.theta3]
                               for r in (c[j].rotation for j in 1:c_count)]...))
    o = permutedims(hcat(offset_series...))
    s = permutedims(hcat(scale_series...))
    r = permutedims(hcat(rotation_series...))

    calplot(x, y, z, xc, yc, zc, o, s, r)
end



end # module
