function farm_step!(FarmAgent, farmModel)

    animalModel = FarmAgent.animalModel

    farmno = FarmAgent.id

        trade_partners = node_neighbors(FarmAgent, farmModel)

       #println(trade_partners)
        
        trade_partner = rand(1:length(trade_partners))

        while trade_partner == farmno
            trade_partner = rand(1:length(trade_partners))
            break
        end

        println("Farm number $farmno can trade")
        println(FarmAgent.animalModel.tradeable_heifers)
        println("Heifers")
        println(FarmAgent.animalModel.tradeable_lactating)
        println("Cows")
        println(FarmAgent.animalModel.tradeable_weaned)
        println("weaned")
        println("Farm number $trade_partner can trade")
        println(farmModel[trade_partner].animalModel.tradeable_heifers)
        println("Heifers")
        println(farmModel[trade_partner].animalModel.tradeable_lactating)
        println("Cows")
        println(farmModel[trade_partner].animalModel.tradeable_weaned)
        println("weaned")
        println("The length of the sending vector is")
        println(length(FarmAgent.animalModel.sending))        
        agents_to_remove = []
        
# Trade heifers ----------------------------------------

        if FarmAgent.animalModel.tradeable_heifers < 0 && farmModel[trade_partner].animalModel.tradeable_heifers > 0
            println("let's trade heifers!")

            FarmAgent.trades_from = FarmAgent.animalModel.sending

            heifers_to_send = []

            if FarmAgent.animalModel.sending == 0
   #             println("No agents to send")
            else
                for i in 1:length(FarmAgent.animalModel.sending)
                    if FarmAgent.animalModel.sending[i].stage == :H
                        push!(heifers_to_send, FarmAgent.animalModel.sending[i])
                    else
  #                      println("No heifers to send")
                    end
                end
            end

 #           println("The candidate number of heifers to send is ")
 #           println(length(heifers_to_send))

            num_trades_to = abs(FarmAgent.animalModel.tradeable_heifers) ≤ length(heifers_to_send) ? abs(FarmAgent.animalModel.tradeable_heifers) : length(heifers_to_send)


#            println("Number of trades to is $num_trades_to")

   

            for i in 1:num_trades_to
                if length(heifers_to_send) != 0
                    push!(farmModel[trade_partner].animalModel.receiving, heifers_to_send[i]) 
                    println("Heifer traded to destination herd")
                    push!(agents_to_remove, heifers_to_send[i])
                    println("Heifer sent to purge list")
                else
 #                   println("No heifers to send")
                end
            end
#            println("This many heifers were sent:")
#            println(length(farmModel[trade_partner].animalModel.receiving))
        end

# Trade lactating  ----------------------------------------

if FarmAgent.animalModel.tradeable_lactating < 0 && farmModel[trade_partner].animalModel.tradeable_lactating > 0
    println("let's trade heifers!")

    FarmAgent.trades_from = FarmAgent.animalModel.sending

    lactating_to_send = []

    if FarmAgent.animalModel.sending == 0
#             println("No agents to send")
    else
        for i in 1:length(FarmAgent.animalModel.sending)
            if FarmAgent.animalModel.sending[i].stage == :L | FarmAgent.animalModel.sending[i].stage == :D
                push!(lactating_to_send, FarmAgent.animalModel.sending[i])
            else
#                      println("No lactating to send")
            end
        end
    end

#           println("The candidate number of heifers to send is ")
#           println(length(heifers_to_send))

    num_trades_to = abs(FarmAgent.animalModel.tradeable_lactating) ≤ length(heifers_to_send) ? abs(FarmAgent.animalModel.tradeable_lactating) : length(lactating_to_send)


#            println("Number of trades to is $num_trades_to")



    for i in 1:num_trades_to
        if length(lactating_to_send) != 0
            push!(farmModel[trade_partner].animalModel.receiving, lactating_to_send[i]) 
            println("Lactating cow traded to destination herd")
            push!(agents_to_remove, lactating_to_send[i])
            println("Lactating cow sent to purge list")
        else
#                   println("No heifers to send")
        end
    end
#            println("This many heifers were sent:")
#            println(length(farmModel[trade_partner].animalModel.receiving))
end
        
# Trade weaned ----------------------------------------

if FarmAgent.animalModel.tradeable_weaned < 0 && farmModel[trade_partner].animalModel.tradeable_weaned > 0
    println("let's trade weaned!")

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
            println("Heifer traded to destination herd")
            push!(agents_to_remove, weaned_to_send[i])
            println("Heifer sent to purge list")
        else
#                   println("No weaned to send")
        end
    end
#            println("This many weaned were sent:")
#            println(length(farmModel[trade_partner].animalModel.receiving))
end


# Remove the traded agents
        for i in 1:length(agents_to_remove)
            if haskey(animalModel.agents, agents_to_remove[i].id) == true

            kill_agent!(agents_to_remove[i].id, animalModel)
            println("Traded agent removed from source farm")
            end  
        end


    step!(FarmAgent.animalModel, agent_step!, model_step!, 1)
    
    farm_id = FarmAgent.id
    num_agents = length(FarmAgent.animalModel.agents)
    
    number_received = length(FarmAgent.animalModel.receiving)
    
    #println("The number of animals received by farm $farm_id is $number_received")
    println("The number of animals in $farm_id is $num_agents ")

    
end