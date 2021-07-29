figure = Figure()
ax = figure[1, 1] = Axis(figure; ylabel = "Infected Sensitive")
l1 = lines!(ax, simRun[:, dataname((:status, infected_sensitive))], color = :orange)
l2 = lines!(ax, simRun[:, dataname((:status, susceptible))], color = :green)
l3 = lines!(ax, simRun[:, dataname((:status, infected_resistant))], color = :red)
l4 = lines!(ax, simRun[:, dataname((:status, recoveries))], color = :black)
figure[1, 2] =
    Legend(figure, [l1], ["Infected Sensitive"])
figure 