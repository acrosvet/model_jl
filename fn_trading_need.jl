"""
 trading_need!(animalModel)
 * Determines percentage variation of current herd size from initial condition, and whether a herd may need to acquire more animals
"""
function trading_need!(animalModel)
    animalModel.tradeable_heifers = animalModel.num_heifers - animalModel.current_heifers
    animalModel.tradeable_weaned = animalModel.num_weaned - animalModel.current_weaned
    animalModel.tradeable_calves = animalModel.num_calves - animalModel.current_calves
    animalModel.tradeable_lactating = animalModel.num_lac - animalModel.current_lac
    animalModel.tradeable_stock = sum(animalModel.tradeable_heifers + animalModel.tradeable_lactating + animalModel.tradeable_weaned + animalModel.tradeable_calves)


end
