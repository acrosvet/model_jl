include("./animal_na.jl");
using Plots

#function run_sims!(times, days)


#results = Array{AnimalData}(undef, times)


#Threads.@threads for i in 1:times
	
    animalModel = initialiseSplit(
      farmno = Int16(1),
      farm_status = Int16(2),
      system = Int16(2),
      msd = Date(2021,9,24),
      seed = Int16(42),
      optimal_stock = Int16(273),
      optimal_lactating = Int16(273),
      treatment_prob = Float16(0.5),
      treatment_length = Int16(4),
      carrier_prob = Float16(0.1),
      timestep = Int16(0),
      density_lactating = Int16(50),
      density_dry = Int16(250),
      density_calves = Int16(3),
      date = Date(2021,7,2),
      vacc_rate = Float16(0.0),
      fpt_rate = Float16(0.0),
      prev_r = Float16(0.01),
      prev_p = Float16(0.01),
      prev_cr = Float16(0.05),
      prev_cp = Float16(0.05),
      vacc_efficacy = Float16(0.1),
      pen_decon = false
    );
@time [animal_step!(animalModel) for i in 1:3651]

transmissions = DataFrame(
  step = animalModel.transmissions.step,
  id = animalModel.transmissions.id,
  stage = animalModel.transmissions.stage,
  from = animalModel.transmissions.from,
  to = animalModel.transmissions.to,
  type = animalModel.transmissions.type
)



plot(countmap(transmissions.type))


CSV.write("./export/transmissions.csv", transmissions)

#= 
  [animal_step!(animalModel) for j in 1:days]
  results[i] = animalModel.sim
end

return results

end

@time runs = run_sims!(1000,3651);

nthreads = Threads.nthreads()

println("Ran a hundred times on $nthreads threads !")

@save "unparm_1000.jld2" runs
 =#