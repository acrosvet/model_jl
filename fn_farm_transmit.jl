function farm_transmit!(FarmAgent, farmModel)

println(typeof(FarmAgent.trades_to))
println(length(FarmAgent.trades_to))

if length(FarmAgent.trades_to) != 0
    for i in 1:length(FarmAgent.trades_to)
        add_agent!(FarmAgent.animalModel, FarmAgent.trades_to[i])
        println("This worked")
    end
end