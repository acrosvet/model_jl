function farm_step!(FarmAgent, farmModel)

    io = open("./export/output.txt", "a")
    


    write(io, "==========================================================\n")
    write(io, "Model step")
    write(io, "==========================================================\n")

    animalModel = FarmAgent.animalModel

    #animalModel.receiving = []

    farmno = FarmAgent.id

        trade_partners = node_neighbors(FarmAgent, farmModel)

       #println(trade_partners)
        
        trade_partner = rand(1:length(trade_partners))

        while trade_partner == farmno
            trade_partner = rand(1:length(trade_partners))
            break
        end

     
        agents_to_remove = []

# If the farm has surplus animals, and the trading partner needs heifers
#= 
println("Sending farm has: \n")
println(FarmAgent.animalModel.tradeable_stock )
println("Receiving frarm has: \n ")
println(farmModel[trade_partner].animalModel.tradeable_stock )
 =#
if FarmAgent.animalModel.tradeable_stock < 0 && farmModel[trade_partner].animalModel.tradeable_stock > 0
    write(io, "let's trade!\n")


    # Create an empty vector of heifers to send to the destination
    stock_to_send = []

    # If there isn't anything to send, quit
    if FarmAgent.animalModel.sending == 0
            println("No agents to send")
    else
        #If not, then select the required stock class to send based on the number of animals avaialble
        for i in 1:length(FarmAgent.animalModel.sending)
                push!(stock_to_send, FarmAgent.animalModel.sending[i])
        end
    end


    # Only send as many heifers as there are avaiable.
    num_trades_from = abs(FarmAgent.animalModel.tradeable_stock) ≤ length(stock_to_send) ? abs(FarmAgent.animalModel.tradeable_stock) : length(stock_to_send)
    
    #Make sure that the farm does not get more than required

    num_trades_to = num_trades_from ≥ abs(farmModel[trade_partner].animalModel.tradeable_stock) ? abs(farmModel[trade_partner].animalModel.tradeable_stock) : num_trades_from

 println("Number of trades to is $num_trades_to")



    for i in 1:num_trades_to
        if length(stock_to_send) != 0
            #Push the ith animal in the sending list to the receiving container in the receiving farm
            push!(farmModel[trade_partner].animalModel.receiving, stock_to_send[i]) 
            write(io, "Heifer traded to destination herd\n")
            #Push the sent animal to the list of animals to be removed
            push!(agents_to_remove, stock_to_send[i])
            write(io, "Stock sent to purge list\n")
        else
                   println("No stockto send")
        end
    end
            println("This many animals were sent:")
            println(length(farmModel[trade_partner].animalModel.receiving))
end

# Remove the traded agents
        for i in 1:length(agents_to_remove)
            # Make sure they are in the agent list
            if haskey(animalModel.agents, agents_to_remove[i].id) == true
            # Kill theagent
            kill_agent!(agents_to_remove[i].id, animalModel)
            write(io, "Traded agent removed from source farm\n")
            end  
        end


# Step the model one step through time        
   # Threads.@spawn for a in allagents(farmModel)
   #     a.animalModel.rng = MersenneTwister(farm_id)
        step!(FarmAgent.animalModel, agent_step!, model_step!, 1)
  #  end
    
    # Return the number of agents in the model at this timestep
    farm_id = FarmAgent.id
    num_agents = length(FarmAgent.animalModel.agents)

    number_received = length(farmModel[trade_partner].animalModel.receiving)

    export_trades!(FarmAgent, farmModel, trade_partner, number_received)

    write(io,"The number of animals received by farm $trade_partner is $number_received\n")
    write(io,"The number of animals in farm $farm_id is $num_agents \n")
    close(io)
    
end