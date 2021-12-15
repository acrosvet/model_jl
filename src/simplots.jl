#using Pkg
#Pkg.add("Plots")
include("animal_na.jl")
using Plots
using JLD2
@load "./export/simrun.jld2"

# Gross numbers 
plt = plot();

for i in 1:length(runs)
  plot!(plt, runs[i].pop_r,  linewidth = 0.5)
end

plot!(plt, title = "Infected resistant (1000 runs)", xlabel = "Model step (days)", ylabel = "Number of animals", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10, legend = false)
savefig("./export/plots/res_1000sim.png")

#as incidence 
plt = plot();

incvec =Array{Float64}(undef, 3651)
for i in 1:length(runs)
  for j in 1:3651
    dat = runs[i].pop_r[j]/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
  plot!(plt, incvec,  linewidth = 0.5)
end

plot!(plt, title = "Resistance incidence (1000 runs)", xlabel = "Model step (days)", ylabel = "Incidence (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false)
savefig("./export/plots/res_inc_1000sim.png")

#as incidence susceptible
plt = plot();

incvec =Array{Float64}(undef, 3651)
for i in 1:length(runs)
  for j in 1:3651
    dat = (runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j] - runs[i].pop_r[j]- runs[i].pop_p[j]- runs[i].pop_er[j]- runs[i].pop_ep[j] - - runs[i].pop_car_r[j]- runs[i].pop_car_p[j]- runs[i].pop_rec_r[j]- runs[i].pop_rec_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
  plot!(plt, incvec,  linewidth = 0.5)
end

plot!(plt, title = "%Susceptible (1000 runs)", xlabel = "Model step (days)", ylabel = "Susceptible (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false)
savefig("./export/plots/suscep_inc_1000sim.png")


plt = plot()
for i in 1:nsims
  plot!(plt, runs[i].pop_p,  linewidth = 0.01)
end
plt
plot!(plt, title = "Infected sensitive (100 sims)", xlabel = "Model step", ylabel = "Number of animals", legend = false)
savefig("./export/plots/sens_100sim.png")


plt = plot()
for i in 1:length(runs)
  plot!(plt, (runs[i].pop_rec_r + runs[i].pop_rec_p),  linewidth = 0.01)
end
plt
plot!(plt, title = "Recovered (1000 sims)", xlabel = "Model step (days)", ylabel = "Number of animals", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10, legend = false)
savefig("./export/plots/recovered_1000sim.png")



plt = plot()
for i in 1:length(runs)
  plot!(plt, runs[i].pop_car_r,  linewidth = 0.01)
end
plt
plot!(plt, title = "Resistant carriers (100 sims)", xlabel = "Model step", ylabel = "Number of animals", legend = false)
savefig("./export/plots/res_carriers_100sim.png")

plt = plot()
for i in 1:nsims
  plot!(plt, runs[i].pop_car_p,  linewidth = 0.01)
end
plt
plot!(plt, title = "Sensitive carriers (100 sims)", xlabel = "Model step", ylabel = "Number of animals", legend = false)
savefig("./export/plots/p_carriers_100sim.png")

plt = plot()
for i in 1:nsims
  plot!(plt, runs[i].num_lactating,  linewidth = 0.01)
end
plt
plot!(plt, title = "Lactating (100 sims)", xlabel = "Model step", ylabel = "Number of animals", legend = false)
savefig("./export/plots/lactating_100sim.png")