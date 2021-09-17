function transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible, inf_stat, to_stat, beta)


    
    interacting_id = interacting_agent.id
    interacting_stage = interacting_agent.stage
    status_contact = interacting_agent.status
    num_contacts = length(possible_interactions)
    status_agent = AnimalAgent.status
    AnimalAgent.dim > 0 && AnimalAgent.dim ≤ 60 ? beta = beta*1.1 : beta = beta
    AnimalAgent.dic > 223 && AnimalAgent.dic < 284 ? beta = beta*1.1 : beta = beta 
    interacting_agent.dim > 0 && interacting_agent.dim ≤ 60 ? beta = beta*1.1 : beta = beta
    interacting_agent.dic > 223 && interacting_agent.dic < 284 ? beta = beta*1.1 : beta = beta 
    if AnimalAgent.status == susceptible && interacting_agent.status == inf_stat
        if rand(animalModel.rng) < beta
            AnimalAgent.status = to_stat
            AnimalAgent.days_exposed += 1
            transmission = "Transmission to agent!"
        else
            transmission = "No transmission"
        end
    elseif interacting_agent.status == inf_stat && AnimalAgent.status == susceptible
        if rand(animalModel.rng) < beta
            interacting_agent.status = to_stat
            AnimalAgent.days_exposed +=1 
            transmission = "Transmission from agent!"
        else
            transmission = "No transmission"
        end
    else
        transmission = "Neither infected"
    end
    export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts, transmission, status_agent, status_contact)


end