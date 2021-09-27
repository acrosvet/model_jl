function farm_step!(FarmAgent, farmModel)

    FarmAgent.trade_status == false

    if Dates.format(farmModel.date, "e") == "Wed" && FarmAgent.trade_status == false
        farm_trader!(FarmAgent, farmModel)
    end
    
      step!(FarmAgent.animalModel, agent_step!, model_step!, 1)

end