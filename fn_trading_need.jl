function trading_need!(animalModel)

    optimal_size = animalModel.herd_size

    current_size = length(animalModel.agents)

    optimal_heifers = Int(floor(0.3*optimal_size))

    optimal_weaned = Int(floor(0.2*optimal_size))

    optimal_calves = Int(floor(0.2*optimal_size))

    optimal_lactating = Int(floor(0.5*(optimal_size - optimal_calves - optimal_heifers - optimal_weaned)))
   
    current_weaned = animalModel.current_weaned
    current_calves = animalModel.current_calves
    current_heifers = animalModel.current_heifers
    current_lactating = animalModel.current_lactating

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
    println("Tradeable calves")
    println(animalModel.tradeable_calves)
    println("Tradeable heifers")
    println(animalModel.tradeable_heifers)
    println("Tradeable lactating")
    println(animalModel.tradeable_lactating)
    println("Tradeable weaned")
    println(animalModel.tradeable_weaned) 

    println("The current herd size is $current_size")
    println("The optimal herd size is $optimal_size")
    println("The optimal number of heifers is $optimal_heifers")
    println("The current number of heifers is $current_heifers")
    println("Difference between optimal and the current number is $heifers_needed")



end