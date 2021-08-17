# Generate some model plots --------------------------------------------------
calfSim = initialiseModel()
model_colors(a) = 
                if a.status == :S 
                        "#afec28"
                elseif a.status == :IS 
                        "#ffa500"
                elseif a.status == :IR
                        "#ff0000"
                elseif a.status == :RS || a.status == :RR
                        "#808080"
                else
                        "#808000"
                end
#a.status == :S ? "#2b2b33" : a.status == :IS ? "#bf2642" : "#338c54"

fig, abmstepper = abm_plot(calfSim; ac = model_colors)
fig # display figure