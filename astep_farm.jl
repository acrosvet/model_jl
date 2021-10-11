function farm_step!(FarmAgent, farmModel)

   # FarmAgent.animalModel.seed = FarmAgent.id
    
   FarmAgent.animalModel.rng = MersenneTwister(hash(FarmAgent))
   FarmAgent.traded = false
   Threads.@spawn step!(FarmAgent.animalModel, agent_step!, model_step!, 1)

    if Dates.format(farmModel.date, "e") == "Wed" && FarmAgent.traded == false
        daytrader!(FarmAgent)
        farm_trader!(FarmAgent, farmModel)
    end
    

end