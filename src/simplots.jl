#using Plots
using JLD2
using Dates
using Pkg

using Plots

filelocs = ["./fpt_1000.jld2", "unparm_1000.jld2", "vacc_1000.jld2"]
runtypes = ["Spring, P(FPT) = 0.5", "Spring, unparametrised", "Spring, P(VACC) = 0.5"]

function gen_plots!(filelocs, runtypes)
    for f in 1:length(filelocs)
      
      runs = jldopen(filelocs[f]) do file
        read(file, "runs")
        end

        runtype = runtypes[f]
        date = Dates.now()
        nruns = "(1000 runs)"
        thisday = Dates.today()
        #as incidence 
        plt = plot();
        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        allvec = Array{Array{Float64}}(undef, length(runs))
        for i in 1:length(runs)
        for j in 1:length(runs[i].pop_r)
            dat = (runs[i].pop_r[j] + runs[i].pop_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        allvec[i] = incvec
        plt = plot!(plt, incvec,  linewidth = 1)
        end
        fig = plot!(plt, title = "Percentage infected $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false);
        savefig(fig, "./export/plots/$thisday Percentage infected $runtype $nruns.png")

        #as incidence susceptible
        plt = plot();
        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        for i in 1:length(runs)
        for j in 1:length(runs[i].pop_r)
            dat = (runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j] - runs[i].pop_r[j]- runs[i].pop_p[j]- runs[i].pop_er[j]- runs[i].pop_ep[j] - - runs[i].pop_car_r[j]- runs[i].pop_car_p[j]- runs[i].pop_rec_r[j]- runs[i].pop_rec_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        plt = plot!(plt, incvec,  linewidth = 1)
        end

        fig = plot!(plt, title = "Percentage susceptible $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Susceptible (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false);
        savefig(fig, "./export/plots/$thisday Percentage susceptible $runtype $nruns.png")

        #Recovered 
        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        plt = plot()
        for i in 1:length(runs)
            for j in 1:length(runs[i].pop_r)
            dat =  (runs[i].pop_rec_r[j] + runs[i].pop_rec_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        plt = plot!(plt, incvec,  linewidth = 1)
        end
        fig = plot!(plt, title = "Recovered animals $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Recovered (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10, legend = false);
        savefig(fig, "./export/plots/$thisday Number recovered $runtype $nruns.png")

        # Resistant 
        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        plt = plot();
        for i in 1:length(runs)
        for j in 1:length(runs[i].pop_r)
            dat = (runs[i].pop_r[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        plt = plot!(plt, incvec,  linewidth = 1)
        end

        fig = plot!(plt, title = "Percentage resistant $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false);
        savefig(fig, "./export/plots/$thisday Percentage resistant $runtype $nruns.png")

        # Pathogenic

        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        plt = plot();
        for i in 1:length(runs)
        for j in 1:length(runs[i].pop_r)
            dat = (runs[i].pop_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        plt = plot!(plt, incvec,  linewidth = 1)
        end

        fig = plot!(plt, title = "Percentage pathogenic $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false);
        savefig(fig, "./export/plots/$thisday Percentage pathogenic $runtype $nruns.png")

        # Carrier total

        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        plt = plot();
        for i in 1:length(runs)
        for j in 1:length(runs[i].pop_r)
            dat = (runs[i].pop_car_r[j] + runs[i].pop_car_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        plt = plot!(plt, incvec,  linewidth = 1)
        end

        fig = plot!(plt, title = "Percentage carrier $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false);
        savefig(fig, "./export/plots/$thisday Percentage carrier $runtype $nruns.png")

        #Carrier resistant
        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        plt = plot();
        for i in 1:length(runs)
        for j in 1:length(runs[i].pop_r)
            dat = (runs[i].pop_car_r[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        plt = plot!(plt, incvec,  linewidth = 1)
        end

        fig = plot!(plt, title = "Percentage carrier (R) $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false);
        savefig(fig, "./export/plots/$thisday Percentage car r  $runtype $nruns.png")

        #Carrier Pathogenic

        incvec =Array{Float64}(undef, length(runs[1].pop_r))
        plt = plot();
        for i in 1:length(runs)
        for j in 1:length(runs[i].pop_r)
            dat = (runs[i].pop_car_p[j])/(runs[i].num_lactating[j] + runs[i].num_calves[j] + runs[i].num_dry[j] + runs[i].num_weaned[j] + runs[i].num_dh[j] + runs[i].num_heifers[j])
            incvec[j] = 100*dat
        end
        plt = plot!(plt, incvec,  linewidth = 1)
        end

        fig = plot!(plt, title = "Percentage carrier (P) $runtype $nruns ($date)", ylims = (0,100), xlabel = "Model step (days)", ylabel = "Infected (%)", titlefontsize = 10, xguidefontsize = 10, yguidefontsize = 10,legend = false);
        savefig(fig, "./export/plots/$thisday Percentage car p $runtype $nruns.png")
    end
end

@time gen_plots!(filelocs, runtypes)