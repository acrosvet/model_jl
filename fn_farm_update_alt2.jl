function farm_update_agent!(FarmAgent, farmModel)

farmno = FarmAgent.id

animalModel = FarmAgent.animalModel

run!(animalModel, agent_step!, model_step!, 1)

println(length(animalModel.agents))

end
