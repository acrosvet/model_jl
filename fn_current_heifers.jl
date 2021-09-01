"""
 current_heifers(animalModel)
 
 * Determine the current number of heifers in an animalModel
 * For use in trading_need!
 * Count the number of AnimalAgents with a stage of :H in a list of agents
 * Check to see if the key is present before incrementing the counter 
"""
function current_heifers(animalModel)
    counter = 0
    for i in 1:length(animalModel.agents)
        if (haskey(animalModel.agents, i) == true) && animalModel.agents[i].stage == :H
            counter += 1
        end
    end
    return counter
end