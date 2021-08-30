function farm_transmit!(FarmAgent, farmModel)

if length(FarmAgent.trades_to) != 0
    for i in 1:length(FarmAgent.trades_to)
        add_agent!(FarmAgent.animalModel, FarmAgent.trades_to[i])
        println("This worked")
    end
end