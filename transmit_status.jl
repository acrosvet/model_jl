function transmit_status!(AnimalAgent, animalModel, possible_interactions; susceptible, inf_stat, to_stat, beta)

for i in 1:length(possible_interactions)
    interacting_agent = animalModel[possible_interactions[i]]
    interacting_id = interacting_agent.id
    interacting_stage = interacting_agent.stage
    status_contact = interacting_agent.status
    num_contacts = length(possible_interactions)
    status_agent = AnimalAgent.status
    if AnimalAgent.status == susceptible && interacting_agent.status == inf_stat
        if rand(animalModel.rng) < beta
            AnimalAgent.status = to_stat
            transmission = "Transmission to agent!"
        else
            transmission = "No transmission"
        end
    elseif interacting_agent.status == inf_stat && AnimalAgent.status == susceptible
        if rand(animalModel.rng) < beta
            interacting_agent.status = to_stat
            transmission = "Transmission from agent!"
        else
            transmission = "No transmission"
        end
    else
        transmission = "Neither infected"
    end
    export_animal_interactions!(AnimalAgent, animalModel, interacting_id, interacting_stage, num_contacts, transmission, status_agent, status_contact)
end

end