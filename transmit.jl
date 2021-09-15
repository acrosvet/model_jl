function transmit!(AnimalAgent, animalModel)
    if AnimalAgent.stage == :C
        possible_interactions =  collect(nearby_ids(AnimalAgent, animalModel, (1, 1, 0)))
        num_contacts = length(possible_interactions)
         if length(possible_interactions) > 0
            interacting_agent = animalModel[possible_interactions[1]]
            interacting_id = interacting_agent.id
            interacting_stage = interacting_agent.stage
         else
            interacting_id = "No contact"
            interacting_stage = "No contact"
        end 
        export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts)
    end

end