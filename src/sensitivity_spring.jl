#Undertake a sensitivity analysis

include("./animal_na.jl");
using Plots
using CSV
using DataFrames

sensitivity_args = DataFrame(CSV.File("./sensitivity_spring.csv"))


function run_it!(optimal_stock, treatment_prob, density_calves, vacc_rate, fpt_rate, vacc_efficacy, pen_decon)

#Threads.@threads for i in 1:times
	
  animalModel = initialiseSpring(
    farmno = Int(1),
    farm_status = Int(2),
    system = Int(1),
    msd = Date(2021,9,24),
    seed = Int(42),
    optimal_stock = Int(optimal_stock),
    optimal_lactating = Int(optimal_stock),
    treatment_prob = Float32(treatment_prob),
    treatment_length = Int(4),
    carrier_prob = Float32(0.1),
    timestep = Int(0),
    density_lactating = 50,
    density_dry = 250,
    density_calves = density_calves,
    date = Date(2021,7,2),
    vacc_rate = Float32(vacc_rate),
    fpt_rate = Float32(fpt_rate),
    prev_r = Float32(0.01),
    prev_p = Float32(0.01),
    prev_cr = Float32(0.05),
    prev_cp = Float32(0.05),
    vacc_efficacy = Float32(vacc_efficacy),
    pen_decon = pen_decon
  );

  [animal_step!(animalModel) for i in 1:3651]

  return animalModel.sim 

end

function run_sense!(sensitivity_args)
    
    results = Array{AnimalData}(undef, length(sensitivity_args.optimal_stock))
    params = Array{Array{Any}}(undef, length(sensitivity_args.optimal_stock))

    Threads.@threads for i in 1:length(sensitivity_args.optimal_stock)
      results[i] =   run_it!(
            sensitivity_args.optimal_stock[i],
            sensitivity_args.treatment_prob[i],
            sensitivity_args.density_calves[i],
            sensitivity_args.vacc_rate[i],
            sensitivity_args.fpt_rate[i],
            sensitivity_args.vacc_efficacy[i],
            sensitivity_args.pen_decon[i]
        )

     params[i] = [
     sensitivity_args.run, 
     sensitivity_args.optimal_stock[i],
     sensitivity_args.treatment_prob[i],
     sensitivity_args.density_calves[i],
     sensitivity_args.vacc_rate[i],
     sensitivity_args.fpt_rate[i],
     sensitivity_args.vacc_efficacy[i]]
    end

    return results, params

end

@time runs = run_sense!(sensitivity_args);

nthreads = Threads.nthreads()

println("Ran a sensitivity analysis!")

@save "sensitivityp_1000.jld2" runs
