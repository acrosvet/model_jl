function farm_transmit!(FarmAgent, farmModel)

println(typeof(FarmAgent.trades_to))
println(length(FarmAgent.trades_to))

if length(FarmAgent.trades_to) != 0
    for i in 1:length(FarmAgent.trades_to)
        agent = FarmAgent.trades_to[i]
        println(agent)
        newid = rand(5000:10000)
        agent.id = newid
        agent.pos = Tuple(10*rand(FarmAgent.animalModel.rng, 2))
        #Works until the second timestep
        add_agent!(agent, FarmAgent.animalModel)
        println("This worked")
    end
end

end