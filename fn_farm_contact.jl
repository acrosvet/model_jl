
function contact!(FarmAgent, farmModel)

        farmno = FarmAgent.id

        trade_partners = node_neighbors(FarmAgent, farmModel)

       # println(trade_partners)
        
        trade_partner = rand(1:length(trade_partners))

        while trade_partner == farmno
            trade_partner = rand(1:length(trade_partners))
            break
        end

        println(FarmAgent.animalModel.tradeable_stock)
        println(farmModel[trade_partner].animalModel.tradeable_stock)

        if FarmAgent.animalModel.tradeable_stock < 0 && farmModel[trade_partner].animalModel.tradeable_stock > 0
            println("let's trade!")
        end

        FarmAgent.trades_from = FarmAgent.animalModel.sending
    
        farmModel[trade_partner].trades_to = FarmAgent.trades_from

        #println(FarmAgent.trades_to)
        
end