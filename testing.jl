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

include("fn_farm_contact.jl")

include("fn_run_submodel.jl")

include("fn_farm_transmit.jl")

include("fn_daytrader.jl")

include("mstep_farm.jl")

step!(farmModel, farm_step!, 10)