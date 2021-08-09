# Generate some model plots --------------------------------------------------
bactoSim = initialisePopulation()
model_colors(a) = 
                if a.bactostatus == :S 
                        "#afec28"
                else a.bactostatus == :R
                        "#ffa500"
                end

fig, abmstepper = abm_plot(bactoSim; ac = model_colors)
fig # display figure