#using Pkg
#Pkg.add("Plots")
include("animal_na.jl")
using Plots
using JLD2

@load "./tmp/hpc_run_mt/model/fpt_1.jld2" 

runtype = "(FPT @ 30%)"
nruns = "(10 runs)"

#as incidence 
plt = plot();

incvec =Array{Float64}(undef, length(runs[1].pop_r))
for i in 1:length(runs)
  for j in 1:length(runs[i].pop_r)
    dat = (runs[i].pop_r[j] + runs[i].pop_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
  plot!(plt, incvec,  linewidth = 1)
end

plot!(plt, title = "Percentage infected $runtype $nruns", ylims = (0,20), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false)
savefig("./export/plots/Percentage infected $runtype $nruns.png")

#as incidence susceptible
plt = plot();

incvec =Array{Float64}(undef, length(runs[1].pop_r))
for i in 1:length(runs)
  for j in 1:length(runs[i].pop_r)
    dat = (runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j] - runs[i].pop_r[j]- runs[i].pop_p[j]- runs[i].pop_er[j]- runs[i].pop_ep[j] - - runs[i].pop_car_r[j]- runs[i].pop_car_p[j]- runs[i].pop_rec_r[j]- runs[i].pop_rec_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
  plot!(plt, incvec,  linewidth = 1)
end

plot!(plt, title = "Percentage susceptible $runtype $nruns", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Susceptible (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false)
savefig("./export/plots/Percentage susceptible $runtype $nruns.png")

incvec =Array{Float64}(undef, length(runs[1].pop_r))
plt = plot()
  for i in 1:length(runs)
    for j in 1:length(runs[i].pop_r)
    dat =  (runs[i].pop_rec_r[j] + runs[i].pop_rec_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
plot!(plt, incvec,  linewidth = 1)
end
plt
plot!(plt, title = "Recovered animals $runtype $nruns", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Recovered (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10, legend = false)
savefig("./export/plots/Number recovered $runtype $nruns.png")

# Years

plt = plot();

incvec =Array{Float64}(undef, length(runs[1].pop_r))
for i in 1:length(runs)
  for j in 1:length(runs[i].pop_r)
    dat = (runs[i].pop_r[j] + runs[i].pop_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
  plot!(plt, incvec[730:1095],  linewidth = 1)
end

plot!(plt, title = "Percentage infected (model year 3) $runtype $nruns", ylims = (0,20), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false)
savefig("./export/plots/Percentage infected y3 $runtype $nruns.png")

#as incidence susceptible
plt = plot();

incvec =Array{Float64}(undef, length(runs[1].pop_r))
for i in 1:length(runs)
  for j in 1:length(runs[i].pop_r)
    dat = (runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j] - runs[i].pop_r[j]- runs[i].pop_p[j]- runs[i].pop_er[j]- runs[i].pop_ep[j] - - runs[i].pop_car_r[j]- runs[i].pop_car_p[j]- runs[i].pop_rec_r[j]- runs[i].pop_rec_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
  plot!(plt, incvec[730:1095],  linewidth = 1)
end

plot!(plt, title = "Percentage susceptible (model year 3) $runtype $nruns", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Susceptible (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false)
savefig("./export/plots/Percentage susceptible y3 $runtype $nruns.png")

incvec =Array{Float64}(undef, length(runs[1].pop_r))
plt = plot()
  for i in 1:length(runs)
    for j in 1:length(runs[i].pop_r)
    dat =  (runs[i].pop_rec_r[j] + runs[i].pop_rec_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
    incvec[j] = 100*dat
  end
plot!(plt, incvec[730:1095],  linewidth = 1)
end
plt
plot!(plt, title = "Recovered animals (model year 3) $runtype $nruns", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Recovered (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10, legend = false)
savefig("./export/plots/Number recovered y3 $runtype $nruns.png")
