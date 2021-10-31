# Animal ABM

include("abm_animal_seasonal.jl")

# Animal transmission functions -------

include("fns_animal_transmission.jl")

# Animal treatment -------------

include("fns_animal_treatment.jl")

# Bacterial dynamics --------------

include("fn_bacteria_dynamics.jl")

# Animal recovery -----------------

include("fn_animal_recovery.jl")


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

#include("abm_farm.jl")

include("fn_farm_contact.jl")

include("fn_run_submodel.jl")

#include("fn_farm_transmit.jl")

include("fn_daytrader.jl")

include("mstep_farm.jl")

include("fn_animal_flag_trades.jl")

include("fn_trading_need.jl")

include("calving.jl")
include("joining.jl")
include("heat.jl")
include("advance_pregnancy.jl")
include("wean.jl")
include("heifer.jl")
include("heifer_joining.jl")
include("bobby_cull.jl")
include("cull_milkers.jl")
include("dryoff.jl")

include("export_animal_data.jl")
include("./abm_animal_split.jl")
include("./abm_animal_batch.jl")
include("abm_animal_yearround.jl")
include("export_animal_position.jl")
include("higher_dimension.jl")
include("transmit.jl")
include("export_animal_position.jl")
include("export_animal_interactions.jl")
include("export_culling.jl")
include("fn_agent_movement.jl")
include("transmit_status.jl")
include("latency.jl")
include("recovery.jl")
include("stock_numbers.jl")
include("send_trades.jl")
include("init_infected_is.jl")
include("init_infected_r.jl")
include("initial_status.jl")
include("mortality.jl")
include("recrudescence.jl")