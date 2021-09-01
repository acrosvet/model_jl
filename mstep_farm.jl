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

        FarmAgent.animalModel.receiving = FarmAgent.trades_to

        #println(farmModel[trade_partner].trades_to)

    step!(FarmAgent.animalModel, agent_step!, model_step!, 1)
    
    farm_id = FarmAgent.id
    num_agents = length(FarmAgent.animalModel.agents)
    
    number_received = length(FarmAgent.animalModel.receiving)
    
    #println("The number of animals received by farm $farm_id is $number_received")
    println("The number of animals in $farm_id is $num_agents ")

    
end