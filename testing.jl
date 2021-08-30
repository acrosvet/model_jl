#tmp = initialiseModel(100)

farmModel = initialiseFarms()

#= agent = tmp[1]
agent.id = 5001
add_agent!(agent, tmp)
step!(tmp, agent_step!, model_step!)

tmp2[1].animalModel
 =#
#add_agent!(agent, tmp2[1].animalModel)

function farm_step!(FarmAgent, farmModel)

    animalModel = FarmAgent.animalModel

    farmno = FarmAgent.id

        trade_partners = node_neighbors(FarmAgent, farmModel)

       #println(trade_partners)
        
        trade_partner = rand(1:length(trade_partners))

        while trade_partner == farmno
            trade_partner = rand(1:length(trade_partners))
            break
        end

        FarmAgent.trades_from = FarmAgent.animalModel.sending
    
        farmModel[trade_partner].trades_to = FarmAgent.trades_from

        #println(farmModel[trade_partner].trades_to)

    step!(FarmAgent.animalModel, agent_step!, model_step!, 1)
    
    farm_id = FarmAgent.id
    num_agents = length(FarmAgent.animalModel.agents)

    println("The number of animals in $farm_id is $num_agents ")
    
end


step!(farmModel, farm_step!, 10)