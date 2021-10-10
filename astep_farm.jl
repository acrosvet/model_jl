function farm_step!(FarmAgent, farmModel)

   # FarmAgent.animalModel.seed = FarmAgent.id
    

    if Dates.format(farmModel.date, "e") == "Wed" && FarmAgent.traded == false
        daytrader!(FarmAgent)
        farm_trader!(FarmAgent, farmModel)
    end
    
    Random.seed!(MersenneTwister(hash(FarmAgent)))
    FarmAgent.animalModel.rng = MersenneTwister(hash(FarmAgent))
    out = @everywhere @async Threads.@spawn step!(FarmAgent.animalModel, agent_step!, model_step!, 1)
    fetch(out)
end