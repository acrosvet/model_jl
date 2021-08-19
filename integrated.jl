# Required packages 
include("packages.jl")

include("agent_types.jl")

# ABM - Bacteria ---------------------------------------
    include("gridsub.jl")

# Def - time resolution ------------


    const time_resolution = 1
    
# Animal ABM

include("abm_animal.jl")

animalModel = initialiseModel()
# Utility functions -------------

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

animalSim = initialiseModel()


# Prepare data -------------------------------
include("export_prepare_adata.jl")

# Run the model 
simRun, _ = run!(animalSim, agent_step!, model_step!, 1825*time_resolution; adata)


# Export to CSV
CSV.write("./integrated_export.csv", simRun)

#include("plot_infection.jl")
#include("plot_pop_dynamics.jl")