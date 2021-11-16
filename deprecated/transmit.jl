function transmit!(AnimalAgent, animalModel)

#Transmission events only occur after the first model step.
    if animalModel.step > 1
        possible_interactions =  collect(nearby_ids(AnimalAgent, animalModel, (1, 1, 0)))#Can only infect other animals on the same z coordinate, else within 1 grid of their position
        num_contacts = length(possible_interactions)#Determine the total number of contacts.
        status_agent = AnimalAgent.status#Set the status of the agent.

         if length(possible_interactions) > 0 #Infections can only occur if there are nearby agents.
            @async Threads.@threads for i in 1:length(possible_interactions)
                interacting_agent = animalModel[possible_interactions[i]]#Set the interacting agent for this iteration
                interacting_id = interacting_agent.id
                interacting_stage = interacting_agent.stage
                status_contact = interacting_agent.status
                num_contacts = length(possible_interactions)
                status_agent = AnimalAgent.status
                if AnimalAgent.status == :RR 
                    transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :RR, to_stat = :ER, beta = AnimalAgent.bactopop_r)#Recovered to RR
                elseif AnimalAgent.status == :RS
                    transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :RS, to_stat = :ES, beta = AnimalAgent.bactopop_is)#Recovered to ER
                elseif AnimalAgent.status == :IS
                    transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :IS, to_stat = :ES, beta = AnimalAgent.bactopop_is)#IS to ES
                elseif AnimalAgent.status == :IR
                    transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :IR, to_stat = :ER, beta = AnimalAgent.bactopop_r)#IR to ER
                elseif AnimalAgent.status == :CR
                    transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :CR, to_stat = :IR, beta = AnimalAgent.bactopop_r)#From carrier
                elseif AnimalAgent.status == :CS
                    transmission = transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible = :S, inf_stat = :CS, to_stat = :IS, beta = AnimalAgent.bactopop_is)#From carrier
                end
                if @isdefined(transmission) == true
                    export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts, transmission, status_agent, status_contact)#Write out the interaction file
                end
            end
        else
            interacting_id = "No effective contact"
            interacting_stage = "No effectivecontact"
            transmission = "No effective contact"
            status_contact = "No effective contact"
            export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts, transmission, status_agent, status_contact)#Append the interaction file even if there is no contact
        end 
    end
end