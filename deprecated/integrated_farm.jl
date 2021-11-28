# Required packages 
include("packages.jl")

include("agent_types.jl")

# ABM - Bacteria ---------------------------------------
include("gridsub.jl")   

# Def - time resolution ------------


const time_resolution = 1
    
# Animal ABM

include("abm_animal.jl")

# Animal transmission functions -------

include("fns_animal_transmission.jl")

# Animal treatment -------------

include("fns_animal_treatment.jl")

# Bacterial dynamics --------------

include("fn_bacteria_dynamics.jl")

# Animal recovery -----------------

include("fn_animal_recovery.jl")

# Fn - Mortality ------------------------------------------------------------    

include("fn_animal_mortality.jl")

# Fn - Bact (agent step) ----------------------------------

include("astep_bacteria.jl")

# Fn - Animal Model Step -------------------------------------

include("mstep_animal.jl")

# Fn - Add new calves -------------------------------------------------------------
include("fn_animal_birth.jl")

# Fn - Animal Agent Step -----------------------------------------------------------    
include("astep_animal.jl")

# Fn - Carrier State ---------------------------------------------    
include("fn_animal_carrier.jl")

# Fn - Update Animal Agent ----------------------------------------------    
include("fn_animal_update.jl")

include("abm_farm.jl")

include("astep_farm.jl")

include("fn_farm_update_alt2.jl")

include("fn_farm_contact.jl")

include("fn_run_submodel.jl")

include("fn_farm_transmit.jl")

infected(x) = count(i == :I for i in x)
recovered(x) = count(i == :S for i in x)

adata = [
    (:status, infected)
    (:status, recovered)
]

data, _ = run!(farmModel, farm_step!)

# Export to CSV 
CSV.write("./integrated_export_1825.csv", simRun)

#include("plot_infection.jl")
#include("plot_pop_dynamics.jl")