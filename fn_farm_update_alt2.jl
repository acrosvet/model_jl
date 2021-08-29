function farm_update_agent!(FarmAgent)

animalModel = FarmAgent.animalModel

include("astep_animal.jl")
include("mstep_animal.jl")

run!(animalModel, agent_step!, model_step!, 1)

end
