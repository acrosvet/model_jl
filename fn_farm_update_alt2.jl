function farm_update_agent!(FarmAgent, farmModel)

farmno = FarmAgent.id

animalModel = FarmAgent.animalModel

run!(animalModel, agent_step!, model_step!, 1)

#=        trade_partners = node_neighbors(FarmAgent, farmModel)
        trade_partner = rand(1:length(trade_partners))
        if trade_partner == farmno 
            println("EXIT!") 
        elseif length(animalModel.sending) != 0 && trade_partner != farmno
            farmModel[trade_partner].animalModel.receiving = animalModel.sending
           # println("traded") 
        end  =#

end
