function transmit!(AnimalAgent, animalModel)
    if animalModel.step > 1
        possible_interactions =  collect(nearby_ids(AnimalAgent, animalModel, (1, 1, 0)))
        num_contacts = length(possible_interactions)
        status_agent = AnimalAgent.status


        if AnimalAgent.inf_days != 0
            AnimalAgent.inf_days +=1 
        elseif AnimalAgent.days_recovered != 0
            AnimalAgent.days_recovered += 1
        elseif  AnimalAgent.days_exposed != 0
            AnimalAgent.days_exposed += 1
        elseif AnimalAgent.days_carrier != 0
            AnimalAgent.days_carrier += 1
        end 
        
         if length(possible_interactions) > 0
            for i in 1:length(possible_interactions)
                interacting_agent = animalModel[possible_interactions[i]]
                interacting_id = interacting_agent.id
                interacting_stage = interacting_agent.stage
                status_contact = interacting_agent.status
                num_contacts = length(possible_interactions)
                status_agent = AnimalAgent.status
                transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :IS, to_stat = :ES, beta = AnimalAgent.bactopop_is)
                transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :IR, to_stat = :ER, beta = AnimalAgent.bactopop_r)
                #transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :carrier_resistant, to_stat = :IS, beta = AnimalAgent.βᵣ/2)
                #transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :carrier_sensitive, to_stat = :IS, beta = AnimalAgent.βₛ/2)
                export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts, transmission, status_agent, status_contact)

            end
        else
            interacting_id = "No contact"
            interacting_stage = "No contact"
            transmission = "No contact"
            status_contact = "No contact"
            export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts, transmission, status_agent, status_contact)
        end 
        
        # increment days infected
        if AnimalAgent.status == :IS || AnimalAgent.status == :IR
            AnimalAgent.inf_days += 1
        elseif AnimalAgent.status == :ES || AnimalAgent.status == :ER
            AnimalAgent.inf_days += 1
        elseif AnimalAgent.status == :recovered
            AnimalAgent.days_recovered += 1
        end



    end
end