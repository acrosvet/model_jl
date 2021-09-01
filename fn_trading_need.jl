"""
 trading_need!(animalModel)
 * Determines percentage variation of current herd size from initial condition, and whether a herd may need to acquire more animals
"""
function trading_need!(animalModel)

    optimal_size = animalModel.herd_size

    current_size = length(animalModel.agents)

    optimal_heifers = 0.3*optimal_size

    optimal_weaned = 0.3*optimal_size

    function current_heifers(animalModel)
        counter = 0
        for i in 1:length(animalModel.agents)
            if animalModel.agents[i].stage == :H
                counter += 1
            end
        end
        return counter
    end

    current_heifers = current_heifers(animalModel)

    println(current_heifers)


end
