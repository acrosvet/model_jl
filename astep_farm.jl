function farm_step!(FarmAgent, farmModel)

   # FarmAgent.animalModel.seed = FarmAgent.id
    
   AnimalAgent.animalModel.rng = MersenneTwister(hash(AnimalAgent))
   AnimalAgent.traded = false
   step!(AnimalAgent.animalModel, agent_step!, model_step!, 1)

    if Dates.format(farmModel.date, "e") == "Wed" && FarmAgent.traded == false
        daytrader!(FarmAgent)
        farm_trader!(FarmAgent, farmModel)
    end
    

end