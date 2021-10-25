using Distributed 

addprocs(16)

include("testing.jl")


   tmp = initialiseSeasonal(220, nbact = 1000, dims = 33, farm_id = 1, farm_status = :R, seed = 42)

   adata = [:pos, :age, :stage, :status, :inf_days, :days_exposed, :days_carrier, :treatment, :days_treated, :bactopop_r, :bactopop_is, :dim, :pregstat, :stress, :sex, :calving_season, :days_recovered]

   mdata = [:num_lac, :current_dry, :current_dh, :current_calves, :current_weaned, :farm_status]

   include("aanimal_headers.jl")

    @time  data_agent,  _ = run!(tmp,  agent_step!, model_step!, 365; adata) 

    open("./export/seasonal_model_run.csv", lock = true,"a") do io
      CSV.write(io, data_agent, delim = ",")
   end

