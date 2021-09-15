function transmit!(AnimalAgent, animalModel)
    if AnimalAgent.stage == :C
        possible_interactions =  collect(nearby_ids(AnimalAgent, animalModel, (1, 1, 0)))
#=         if length(possible_interactions) > 0
            interacting_agent = animalModel[possible_interactions[1]]
         println(interacting_agent.stage)
        end =#
    end
end