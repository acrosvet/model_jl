function transmit!(AnimalAgent, animalModel)
        possible_interactions =  collect(nearby_ids(AnimalAgent, animalModel, (1, 1, 0)))
        num_contacts = length(possible_interactions)
        status_agent = AnimalAgent.status

        
         if length(possible_interactions) > 0
            transmit_status!(AnimalAgent, animalModel, possible_interactions; susceptible = :S, inf_stat = :IS, to_stat = :ES, beta = AnimalAgent.βₛ)

        else
            interacting_id = "No contact"
            interacting_stage = "No contact"
            transmission = "No contact"
            status_contact = "No contact"
            export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts, transmission, status_agent, status_contact)
        end 
        


end