
function contact!(FarmAgent, farmModel)

        farmno = FarmAgent.id

        trade_partners = node_neighbors(FarmAgent, farmModel)

       # println(trade_partners)
        
        trade_partner = rand(1:length(trade_partners))

        while trade_partner == farmno
            trade_partner = rand(1:length(trade_partners))
            break
        end

        println(trade_partner)

        farmModel[trade_partner].animalModel.receiving = FarmAgent.animalModel.sending

        println(FarmAgent.animalModel.sending)
        println(farmModel[trade_partner].animalModel.receiving)
end