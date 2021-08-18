figure = Figure()
ax = figure[1, 1] = Axis(figure; ylabel = "Number of animals")
l1 = lines!(ax, simRun[:, dataname((:stage, stage_c))], color = :orange)
l2 = lines!(ax, simRun[:, dataname((:stage, stage_w))], color = :green)
l3 = lines!(ax, simRun[:, dataname((:stage, stage_h))], color = :red)
l4 = lines!(ax, simRun[:, dataname((:stage, stage_l))], color = :black)


figure  