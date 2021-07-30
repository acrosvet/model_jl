figure = Figure()
ax = figure[1, 1] = Axis(figure; ylabel = "Number of calves")
l1 = lines!(ax, simRun[:, dataname((:status, infected_sensitive))], color = :orange)
l2 = lines!(ax, simRun[:, dataname((:status, susceptible))], color = :green)
l3 = lines!(ax, simRun[:, dataname((:status, infected_resistant))], color = :red)
l4 = lines!(ax, simRun[:, dataname((:status, recoveries_r))], color = :black)
l5 = lines!(ax, simRun[:, dataname((:status, recoveries_s))], color = :grey)


figure 