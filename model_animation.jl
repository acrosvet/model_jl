abm_video(
    "./CalfModel.mp4",
    calfSim,
    agent_step!,
    model_step!;
    title = "Calf model",
    frames = 100,
    ac = model_colors,
    as = 10,
    spf = 1,
    framerate = 20,
)