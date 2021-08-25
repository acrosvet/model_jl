
function contact!(FarmAgent, farmModel)
    
    #submodel = agent.submodel

    trade_partners = node_neighbors(FarmAgent, farmModel)

    trade_partner = rand(1:length(trade_partners))
end