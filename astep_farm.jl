function farm_step!(FarmAgent, farmModel)

    daytrader!(FarmAgent)

    if Dates.format(farmModel.date, "e") == "Wed" && FarmAgent.traded == false
        farm_trader!(FarmAgent, farmModel)
    end
    
    step!(FarmAgent.animalModel, agent_step!, model_step!, 1)

end