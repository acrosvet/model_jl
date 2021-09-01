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

        println("Farm number $farmno can trade")
        println(FarmAgent.animalModel.tradeable_stock)
        println("Farm number $trade_partner can trade")
        println(farmModel[trade_partner].animalModel.tradeable_stock)

        if FarmAgent.animalModel.tradeable_stock < 0 && farmModel[trade_partner].animalModel.tradeable_stock > 0
            println("let's trade!")

            FarmAgent.trades_from = FarmAgent.animalModel.sending

            num_trades_to = abs(FarmAgent.animalModel.tradeable_stock)

            for i in 1:num_trades_to
                if length(FarmAgent.animalModel.sending) != 0
                    push!(farmModel[trade_partner].animalModel.receiving, FarmAgent.animalModel.sending[i]) 
                    println("Agent traded to destination herd")
                    if haskey(animalModel.agents, FarmAgent.animalModel.sending[i].id) == true

                        kill_agent!(FarmAgent.animalModel.sending[i].id, animalModel)
                        println("Traded agent removed from source herd")
                   end 
                else
                    println("Send list empty")
                end
            end

            println(length(farmModel[trade_partner].animalModel.receiving))
        end


#=         FarmAgent.trades_from = FarmAgent.animalModel.sending
    
        farmModel[trade_partner].trades_to = FarmAgent.trades_from

        FarmAgent.animalModel.receiving = FarmAgent.trades_to
 =#
        #println(farmModel[trade_partner].trades_to)

    step!(FarmAgent.animalModel, agent_step!, model_step!, 1)
    
    farm_id = FarmAgent.id
    num_agents = length(FarmAgent.animalModel.agents)
    
    number_received = length(FarmAgent.animalModel.receiving)
    
    #println("The number of animals received by farm $farm_id is $number_received")
    println("The number of animals in $farm_id is $num_agents ")

    
end