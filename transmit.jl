function transmit!(AnimalAgent, animalModel)
        possible_interactions =  collect(nearby_ids(AnimalAgent, animalModel, (1, 1, 0)))
        num_contacts = length(possible_interactions)
        
         if length(possible_interactions) > 0
            for i in 1:length(possible_interactions)
                interacting_agent = animalModel[possible_interactions[i]]
                interacting_id = interacting_agent.id
                interacting_stage = interacting_agent.stage
                export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts)
            end
        else
            interacting_id = "No contact"
            interacting_stage = "No contact"
            export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts)
        end 
        


end