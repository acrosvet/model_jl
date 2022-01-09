#= using Distributed
addprocs(16)
 =#
include("./animal_na.jl");

nruns = 1
nsims = 10
nyears = 10
 
function gen_models!(i)


  global animalModel 
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
  carrier_prob = Float32(0.05),
  timestep = Int16(0),
  density_lactating = Int8(6),
  density_dry = Int8(7),
  density_calves = Int8(3),
  date = Date(2021,7,2),
  vacc_rate = Float32(0.0),
  fpt_rate = Float32(0.0),
  prev_r = Float32(0.01),
  prev_p = Float32(0.01),
  prev_cr = Float32(0.04),
  prev_cp = Float32(0.04),
  vacc_efficacy = Float32(0.1)
)

  animalModel.rng = MersenneTwister(i)

  for j in 1:length(animalModel.animals)
      animalModel.animals[j].bacteriaSubmodel.rng = MersenneTwister(hash(animalModel.animals[j]))
  end

  return animalModel

end


#@time [animal_step!(animalModel, animalData) for i in 1:365]
function run_sims!(nsims, nyears, runseq)
  models = Array{AnimalModel}(undef, nsims)
  modelData = Array{AnimalData}(undef, nsims)

  for i in 1:nsims
    models[i] = gen_models!(i)
  end

  for i in 1:nsims
    modelData[i] = AnimalData([0], [Date(0)], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0], [0])
  end
    
    global runs
    runs = Array{AnimalData}(undef,nsims)
  
    #write_allData!(allData)
  t = @task begin

    Threads.@threads for i in 1:nsims
      animalData = modelData[i]
      animalModel = models[i]
      [animal_step!(animalModel, animalData) for j in 1:nyears*365]
      runs[i] = animalData
    end



  end
  #write("data", runs)

  schedule(t)

  fetch(t)

  while isassigned(runs, nsims) == true
    @save "simrun_unparm$runseq.jld2" runs
    break
  end
  


end
 #fetch(t)


@time for i in 1:nruns
  run_sims!(nsims, nyears, i)
end

  






