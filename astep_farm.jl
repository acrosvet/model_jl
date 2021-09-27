function farm_step!(FarmAgent, farmModel)

    if Dates.format(farmModel.date, "e") == "Wed"
        farm_trader!(FarmAgent, farmModel)
    end
    
      step!(FarmAgent.animalModel, agent_step!, model_step!, 1)

end