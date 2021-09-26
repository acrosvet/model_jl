function farm_step!(FarmAgent, farmModel)
    
    #contact!(FarmAgent, farmModel)

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

#=         println("Sending farm number $farmno can trade")
        println(FarmAgent.animalModel.tradeable_heifers)
        println("Heifers")
        println(FarmAgent.animalModel.tradeable_lactating)
        println("Cows")
        println(FarmAgent.animalModel.tradeable_weaned)
        println("weaned")
        println("Receiving farm number $trade_partner can trade")
        println(farmModel[trade_partner].animalModel.tradeable_heifers)
        println("Heifers")
        println(farmModel[trade_partner].animalModel.tradeable_lactating)
        println("Cows")
        println(farmModel[trade_partner].animalModel.tradeable_weaned)
        println("weaned")
        println("The length of the sending vector in the sending farm is:")
        println(length(FarmAgent.animalModel.sending))   =#      
        agents_to_remove = []

# If the farm has surplus animals, and the trading partner needs heifers
if FarmAgent.animalModel.tradeable_stock < 0 && farmModel[trade_partner].animalModel.tradeable_stock > 0
    write(io, "let's trade!\n")

    #FarmAgent.trades_from = FarmAgent.animalModel.sending

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
    end

    # Only send as many heifers as there are avaiable.
    num_trades_from = abs(FarmAgent.animalModel.tradeable_stock) ≤ length(stock_to_send) ? abs(FarmAgent.animalModel.tradeable_stock) : length(stock_to_send)
    
    #Make sure that the farm does not get more than required

    num_trades_to = num_trades_from ≥ abs(farmModel[trade_partner].animalModel.tradeable_stock) ? abs(farmModel[trade_partner].animalModel.tradeable_stock) : num_trades_from

#            println("Number of trades to is $num_trades_to")



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

        #=        
        FarmAgent.trades_from = FarmAgent.animalModel.sending
#=     
        farmModel[trade_partner].trades_to = FarmAgent.trades_from =#
# Trade heifers ----------------------------------------



        # If the farm has surplus animals, and the trading partner needs heifers
        if FarmAgent.animalModel.tradeable_heifers < 0 && farmModel[trade_partner].animalModel.tradeable_heifers > 0
            write(io, "let's trade heifers!\n")

            #FarmAgent.trades_from = FarmAgent.animalModel.sending

            # Create an empty vector of heifers to send to the destination
            heifers_to_send = []

            # If there isn't anything to send, quit
            if FarmAgent.animalModel.sending == 0
   #             println("No agents to send")
            else
                #If not, then select the required stock class to send based on the number of animals avaialble
                for i in 1:length(FarmAgent.animalModel.sending)
                    if FarmAgent.animalModel.sending[i].stage == :H
                        #Push each agent to the sending vector
                        push!(heifers_to_send, FarmAgent.animalModel.sending[i])
                    else
  #                      println("No heifers to send")
                    end
                end
            end

 #           println("The candidate number of heifers to send is ")
 #           println(length(heifers_to_send))

            # Only send as many heifers as there are avaiable.
            num_trades_from = abs(FarmAgent.animalModel.tradeable_heifers) ≤ length(heifers_to_send) ? abs(FarmAgent.animalModel.tradeable_heifers) : length(heifers_to_send)
            
            #Make sure that the farm does not get more than required

            num_trades_to = num_trades_from ≥ abs(farmModel[trade_partner].animalModel.tradeable_heifers) ? abs(farmModel[trade_partner].animalModel.tradeable_heifers) : num_trades_from

#            println("Number of trades to is $num_trades_to")

   

            for i in 1:num_trades_to
                if length(heifers_to_send) != 0
                    #Push the ith animal in the sending list to the receiving container in the receiving farm
                    push!(farmModel[trade_partner].animalModel.receiving, heifers_to_send[i]) 
                    write(io, "Heifer traded to destination herd\n")
                    #Push the sent animal to the list of animals to be removed
                    push!(agents_to_remove, heifers_to_send[i])
                    write(io, "Heifer sent to purge list\n")
                else
 #                   println("No heifers to send")
                end
            end
#            println("This many heifers were sent:")
#            println(length(farmModel[trade_partner].animalModel.receiving))
        end

# Trade lactating  ----------------------------------------

if FarmAgent.animalModel.tradeable_lactating < 0 && farmModel[trade_partner].animalModel.tradeable_lactating > 0
    write(io,"let's trade lactating cows!\n")

    FarmAgent.trades_from = FarmAgent.animalModel.sending

    lactating_to_send = []

    if FarmAgent.animalModel.sending == 0
#             println("No agents to send")
    else
        for i in 1:length(FarmAgent.animalModel.sending)
            if FarmAgent.animalModel.sending[i].stage == :L || FarmAgent.animalModel.sending[i].stage == :D
                push!(lactating_to_send, FarmAgent.animalModel.sending[i])
            else
#                      println("No lactating to send")
            end
        end
    end

#           println("The candidate number of heifers to send is ")
#           println(length(lactating_to_send))

    num_trades_to = abs(FarmAgent.animalModel.tradeable_lactating) ≤ length(lactating_to_send) ? abs(FarmAgent.animalModel.tradeable_lactating) : length(lactating_to_send)


#            println("Number of trades to is $num_trades_to")



    for i in 1:num_trades_to
        if length(lactating_to_send) != 0
            push!(farmModel[trade_partner].animalModel.receiving, lactating_to_send[i]) 
            write(io,"Lactating cow traded to destination herd\n")
            push!(agents_to_remove, lactating_to_send[i])
            write(io,"Lactating cow sent to purge list\n")
        else
#                   println("No heifers to send")
        end
    end
#            println("This many heifers were sent:")
#            println(length(farmModel[trade_partner].animalModel.receiving))
end
        
# Trade weaned ----------------------------------------

if FarmAgent.animalModel.tradeable_weaned < 0 && farmModel[trade_partner].animalModel.tradeable_weaned > 0
    write(io,"let's trade weaned!")

    FarmAgent.trades_from = FarmAgent.animalModel.sending

    weaned_to_send = []

    if FarmAgent.animalModel.sending == 0
#             println("No agents to send")
    else
        for i in 1:length(FarmAgent.animalModel.sending)
            if FarmAgent.animalModel.sending[i].stage == :W
                push!(weaned_to_send, FarmAgent.animalModel.sending[i])
            else
#                      println("No weaned to send")
            end
        end
    end

#           println("The candidate number of weaned to send is ")
#           println(length(weaned_to_send))

    num_trades_to = abs(FarmAgent.animalModel.tradeable_weaned) ≤ length(weaned_to_send) ? abs(FarmAgent.animalModel.tradeable_weaned) : length(weaned_to_send)


#            println("Number of trades to is $num_trades_to")



    for i in 1:num_trades_to
        if length(weaned_to_send) != 0
            push!(farmModel[trade_partner].animalModel.receiving, weaned_to_send[i]) 
            write(io, "Weaned traded to destination herd\n")
            push!(agents_to_remove, weaned_to_send[i])
            write(io,"Weaned sent to purge list\n")
        else
#                   println("No weaned to send")
        end
    end
#            println("This many weaned were sent:")
#            println(length(farmModel[trade_partner].animalModel.receiving))
end

 =#
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

    write(io,"The number of animals received by farm $trade_partner is $number_received\n")
    write(io,"The number of animals in farm $farm_id is $num_agents \n")
    close(io)
    
end