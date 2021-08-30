
function contact!(FarmAgent, farmModel)

        farmno = FarmAgent.id

        trade_partners = node_neighbors(FarmAgent, farmModel)

       # println(trade_partners)
        
        trade_partner = rand(1:length(trade_partners))

        while trade_partner == farmno
            trade_partner = rand(1:length(trade_partners))
            break
        end

        FarmAgent.trades_from = FarmAgent.animalModel.sending
    
        farmModel[trade_partner].trades_to = FarmAgent.trades_from

        println(FarmAgent.trades_to)
        
end