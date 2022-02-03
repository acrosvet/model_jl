#= using Distributed
addprocs(16) =#


 include("./animal_na.jl");

animalModel = initialiseSpring(
  farmno = Int8(1),
  farm_status = Int8(2),
  system = Int8(1),
  msd = Date(2021,9,24),
  seed = Int8(42),
  optimal_stock = Int16(273),
  optimal_lactating = Int16(273),
  treatment_prob = Float32(0),
  treatment_length = Int8(3),
  carrier_prob = Float32(0.01),
  timestep = Int16(0),
  density_lactating = Int8(6),
  density_dry = Int8(7),
  density_calves = Int8(3),
  date = Date(2021,7,2),
  vacc_rate = Float32(0.0),
  fpt_rate = Float32(0.0),
  prev_r = Float32(0.01),
  prev_p = Float32(0.01),
  prev_cr = Float32(0.05),
  prev_cp = Float32(0.05),
  vacc_efficacy = Float32(0.1)
);

function run_sims(animalModel)
  [animal_step!(animalModel) for i in 1:3651]
end


runs = Array{AnimalModel}(undef, 100)

function sim_runs()
 Threads.@threads  for i in 1:100
  runs[i] = deepcopy(animalModel)
  run_sims(runs[i])
  end
end

@time sim_runs()

@save "spring_unparm_mt.jld2" runs
