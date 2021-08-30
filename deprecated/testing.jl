tmp = initialiseModel(100)

tmp2 = initialiseFarms()

agent = tmp[1]
agent.id = 5001
add_agent!(agent, tmp)
step!(tmp, agent_step!, model_step!)

tmp2[1].animalModel

add_agent!(agent, tmp2[1].animalModel)

function farm_step!(FarmAgent, farmModel)

    animalModel = FarmAgent.animalModel

    step!(animalModel, agent_step!, model_step!, 1)
    
end


step!(tmp2, farm_step!)