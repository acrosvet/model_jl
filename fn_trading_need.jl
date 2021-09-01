"""
 trading_need!(animalModel)
 * Determines percentage variation of current herd size from initial condition, and whether a herd may need to acquire more animals
"""
function trading_need!(animalModel)

    optimal_size = animalModel.herd_size

    current_size = length(animalModel.agents)

    optimal_heifers = Int(floor(0.3*optimal_size))

    optimal_weaned = Int(floor(0.2*optimal_size))

    optimal_calves = Int(floor(0.2*optimal_size))

    optimal_lactating = Int(floor(0.5*(optimal_size - optimal_calves - optimal_heifers - optimal_weaned)))
   
    function current_stock(animalModel, stage)
        counter = 0
        for i in 1:length(animalModel.agents)
            if (haskey(animalModel.agents, i) == true) && animalModel.agents[i].stage == stage
                counter += 1
            end
        end
        return counter

    end
    current_weaned = current_stock(animalModel, :W)
    current_calves = current_stock(animalModel, :C)
    current_heifers = current_stock(animalModel, :H)
    current_lactating = current_stock(animalModel, :L)

    tradeable_heifers = optimal_heifers - current_heifers
    tradeable_weaned = optimal_weaned - current_weaned
    tradeable_calves = optimal_calves - current_calves
    tradeable_lactating = optimal_lactating - current_lactating
    tradeable_stock = optimal_size - current_size

    animalModel.tradeable_calves = tradeable_calves
    animalModel.tradeable_heifers = tradeable_heifers
    animalModel.tradeable_lactating = tradeable_lactating
    animalModel.tradeable_weaned = tradeable_weaned
    animalModel.tradeable_stock = tradeable_stock

    println("The currently tradeable_stock is:")
    println(animalModel.tradeable_stock)
#=      println("Tradeable calves")
    println(animalModel.tradeable_calves)
    println("Tradeable heifers")
    println(animalModel.tradeable_heifers)
    println("Tradeable lactating")
    println(animalModel.tradeable_lactating)
    println("Tradeable weaned")
    println(animalModel.tradeable_weaned) 
 =#
#= 
    println("The current herd size is $current_size")
    println("The optimal herd size is $optimal_size")
    println("The optimal number of heifers is $optimal_heifers")
    println("The current number of heifers is $current_heifers")
    println("Difference between optimal and the current number is $heifers_needed")
 =#


end
