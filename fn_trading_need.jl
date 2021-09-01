"""
 trading_need!(animalModel)
 * Determines percentage variation of current herd size from initial condition, and whether a herd may need to acquire more animals
"""
function trading_need!(animalModel)

    optimal_size = animalModel.herd_size

    current_size = length(animalModel.agents)

    optimal_heifers = 0.3*optimal_size

    optimal_weaned = 0.3*optimal_size

    current_heifers = current_heifers(animalModel)

    println("The current number of heifers is $current_heifers")


end
