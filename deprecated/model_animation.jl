# Generate some model plots --------------------------------------------------
calfSim = initialiseModel()
model_colors(a) = 
                if a.status == :S 
                        "#00FF00"
                elseif a.status == :IS 
                        "#800000"
                elseif a.status == :IR
                        "#FF0000"
                elseif a.status == :RS || a.status == :RR
                        "#000000"
                elseif a.status == :CR || a.status == :CS
                        "#808080"
                end
#a.status == :S ? "#2b2b33" : a.status == :IS ? "#bf2642" : "#338c54"


abm_video(
    "CalfModel.mp4",
    calfSim,
    agent_step!,
    model_step!;
    title = "Calf model",
    frames = 100*time_resolution,
    ac = model_colors,
    as = 10,
    spf = 1,
    framerate = 20,
)