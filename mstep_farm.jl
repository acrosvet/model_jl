function farm_mstep!(farmModel)
    

farmModel.date += Day(1)
farmModel.step += 1

for a in allagents(farmModel)
    a.rng = MersenneTwister(hash(a))
    a.traded = false
     step!(a.animalModel, agent_step!, model_step!, 1)
end


end