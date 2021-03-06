# Load packages
include("packages.jl")

# Agent and time resolution

include("define_agent.jl")

# Set the initial state

include("model_initialise.jl")

# Stepping functions

include("step_function.jl")
include("agent_step.jl")
include("periodic_position.jl")

# Updating function

include("agent_update.jl")

# Transmission functions

include("transmit_resistant.jl")
include("transmit_sensitive.jl")
include("transmit_carrier_is.jl")
include("transmit_carrier_ir.jl")

#Carrier state
include("carrier_state.jl")

# Mortality and recovery

include("mortality.jl")
include("recover.jl")
include("treatment.jl")
include("treatment_end.jl")
include("treatment_effect.jl")
include("retreatment.jl")

# Plotting

include("plot_static.jl")

# Run simulations

include("run_simulation.jl")

# Plot simulations
include("plot_simulations.jl")

