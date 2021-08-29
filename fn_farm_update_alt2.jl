function farm_update_agent!(FarmAgent)

animalModel = FarmAgent.animalModel



run!(animalModel, agent_step!, model_step!, 1)

println(animalModel.sending)

end
