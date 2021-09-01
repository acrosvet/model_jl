"""
 trading_need!(animalModel)
 * Determines percentage variation of current herd size from initial condition, and whether a herd may need to acquire more animals
"""
function trading_need!(animalModel)

    optimal_size = animalModel.herd_size

    current_size = length(animalModel.agents)

    optimal_heifers = Int(floor(0.3*optimal_size))

    optimal_weaned = 0.3*optimal_size
   
    function current_heifers(animalModel)
        counter = 0
        for i in 1:length(animalModel.agents)
            if (haskey(animalModel.agents, i) == true) && animalModel.agents[i].stage == :H
                counter += 1
            end
        end
        return counter

    end


    current_heifers = current_heifers(animalModel)

    heifers_needed = optimal_heifers - current_heifers

    println("The current herd size is $current_size")
    println("The optimal herd size is $optimal_size")
    println("The optimal number of heifers is $optimal_heifers")
    println("The current number of heifers is $current_heifers")
    println("Difference between optimal and the current number is $heifers_needed")


end
