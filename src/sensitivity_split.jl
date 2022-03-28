#Undertake a sensitivity analysis

include("./animal_na.jl");
using Plots
using CSV
using DataFrames
using Distributed, SlurmClusterManager 
addprocs(SlurmManager())
sensitivity_args = DataFrame(CSV.File("./sensitivity_split.csv"))
#sensitivity_args = first(sensitivity_args,1)


function run_it!(optimal_stock, treatment_prob, density_calves, vacc_rate, fpt_rate, vacc_efficacy, pen_decon, run)

	
  animalModel = initialiseSplit(
    farmno = Int16(1),
    farm_status = Int16(2),
    system = Int16(2),
    msd = Date(2021,9,24),
    seed = Int16(42),
    optimal_stock = Int16(optimal_stock),
    optimal_lactating = Int16(optimal_stock),
    treatment_prob = Float16(treatment_prob),
    treatment_length = Int16(4),
    carrier_prob = Float16(0.1),
    timestep = Int16(0),
    density_lactating = Int16(50),
    density_dry = Int16(250),
    density_calves = Int16(density_calves),
    date = Date(2021,7,2),
    vacc_rate = Float16(vacc_rate),
    fpt_rate = Float16(fpt_rate),
    prev_r = Float16(0.01),
    prev_p = Float16(0.01),
    prev_cr = Float16(0.05),
    prev_cp = Float16(0.05),
    vacc_efficacy = Float16(vacc_efficacy),
    pen_decon = pen_decon
  );

  [animal_step!(animalModel) for i in 1:3651]

  seq = run

  data = DataFrame(
    id = animalModel.sim.id,
    timestep= animalModel.sim.timestep,
    pop_r = animalModel.sim.pop_r,
    pop_s= animalModel.sim.pop_s,
    pop_p= animalModel.sim.pop_p,
    pop_d= animalModel.sim.pop_d,
    pop_rec_r= animalModel.sim.pop_rec_r,
    pop_rec_p= animalModel.sim.pop_rec_p,
    pop_car_p= animalModel.sim.pop_car_p,
    pop_car_r= animalModel.sim.pop_car_r,
    num_calves= animalModel.sim.num_calves,
    num_dh= animalModel.sim.num_dh,
    num_heifers= animalModel.sim.num_heifers,
    num_lactating= animalModel.sim.num_lactating,
    num_dry= animalModel.sim.num_dry,
    pop_er= animalModel.sim.pop_er,
    pop_ep= animalModel.sim.pop_ep,
    inf_calves= animalModel.sim.inf_calves,
    inf_heifers= animalModel.sim.inf_heifers,
    inf_weaned= animalModel.sim.inf_weaned,
    inf_dh= animalModel.sim.inf_dh,
    inf_dry= animalModel.sim.inf_dry,
    inf_lac= animalModel.sim.inf_lac,
    #inf_pens= animalModel.sim.num_calves,
    clinical= animalModel.sim.clinical,
    subclinical= animalModel.sim.subclinical,
    current_b1= animalModel.sim.current_b1,
    current_b2= animalModel.sim.current_b2,
    current_b3= animalModel.sim.current_b3,
    current_b4= animalModel.sim.current_b4
  )
  CSV.write("./export/split_sense $seq.csv", data)
  
  return animalModel.sim 
  #return animalModel
end

function run_sense!(sensitivity_args)
    
    Threads.@threads for i in 1:length(sensitivity_args.optimal_stock)

      @time  run_it!(
            Int16(sensitivity_args.optimal_stock[i]),
            Float16(sensitivity_args.treatment_prob[i]),
            Int16(sensitivity_args.density_calves[i]),
            Float16(sensitivity_args.vacc_rate[i]),
            Float16(sensitivity_args.fpt_rate[i]),
            Float16(sensitivity_args.vacc_efficacy[i]),
            sensitivity_args.pen_decon[i],
            sensitivity_args.seq[i]
        )

     @info "Run complete"

    end




end

@time runs = run_sense!(sensitivity_args);

nthreads = Threads.nthreads()

println("Ran a sensitivity analysis!")

@save "sensitivitysplit_1000.jld2" runs
