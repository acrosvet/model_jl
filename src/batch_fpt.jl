include("./animal_na.jl");

runtype = "batch_fpt_50_1000"

function run_sims!(times, days)


results = Array{AnimalData}(undef, times)


Threads.@threads for i in 1:times
	
animalModel = initialiseBatch(
  farmno = Int8(1),
  farm_status = Int8(2),
  system = Int8(2),
  msd = Date(2021,9,24),
  seed = Int8(42),
  optimal_stock = Int16(273),
  optimal_lactating = Int16(273),
  treatment_prob = Float32(0.0),
  treatment_length = Int8(3),
  carrier_prob = Float32(0.05),
  timestep = Int16(0),
  density_lactating = Int8(6),
  density_dry = Int8(7),
  density_calves = Int8(3),
  date = Date(2021,7,2),
  vacc_rate = Float32(0.0),
  fpt_rate = Float32(0.5),
  prev_r = Float32(0.01),
  prev_p = Float32(0.01),
  prev_cr = Float32(0.04),
  prev_cp = Float32(0.04),
  vacc_efficacy = Float32(0.1)
)


[animal_step!(animalModel) for j in 1:days]
results[i] = animalModel.sim
end

return results

end

@time runs = run_sims!(1000,3651);

nthreads = Threads.nthreads()

println("Ran a thousand times on $nthreads threads !")

timestamp = now()

@save "$runtype $timestamp.jld2" runs