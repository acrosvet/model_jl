function transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible, inf_stat, to_stat, beta)
    if AnimalAgent.status == inf_stat && interacting_agent.status == susceptible
        beta < 0.1 ? beta = 0 : beta = beta
        if rand(animalModel.rng) < beta
            interacting_agent.status = to_stat
            interacting_agent.submodel.total_status = to_stat
            interacting_agent.days_exposed = 1
            interacting_agent.inf_days = 0
            transmission = "Transmission to agent!"
        else
            transmission = "No transmission"
        end
    end
return transmission

end