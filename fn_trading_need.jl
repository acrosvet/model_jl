function trading_need!(animalModel)

    optimal_lactating = animalModel.N

    current_size = length(animalModel.agents)

    optimal_heifers = Int(floor(0.2*optimal_lactating))

    optimal_weaned = Int(floor(0.2*optimal_lactating))

    optimal_calves = Int(floor(0.2*optimal_lactating))

    optimal_size = Int(floor(current_size * rand(animalModel.rng, 0.9:0.1:1.1)))
   
    current_weaned = animalModel.current_weaned
    current_calves = animalModel.current_calves
    current_heifers = animalModel.current_heifers
    current_lactating = animalModel.current_lac

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



end