function transmit_status!(AnimalAgent, animalModel, interacting_agent, possible_interactions; susceptible, inf_stat, to_stat, beta)
    AnimalAgent.dim > 0 && AnimalAgent.dim ≤ 60 ? beta = beta*1.1 : beta = beta
    AnimalAgent.dic > 223 && AnimalAgent.dic < 284 ? beta = beta*1.1 : beta = beta 
    interacting_agent.dim > 0 && interacting_agent.dim ≤ 60 ? beta = beta*1.1 : beta = beta
    interacting_agent.dic > 223 && interacting_agent.dic < 284 ? beta = beta*1.1 : beta = beta 
    if AnimalAgent.status == susceptible && interacting_agent.status == inf_stat
        beta_int = interacting_agent.status == :IR ? interacting_agent.bactopop_r : interacting_agent.bactopop_is
        if rand(animalModel.rng) < beta_int
            AnimalAgent.status = to_stat
            AnimalAgent.submodel.total_status = to_stat
            AnimalAgent.days_exposed = 1
            transmission = "Transmission to agent!"
        else
            transmission = "No transmission"
        end
    elseif interacting_agent.status == susceptible && AnimalAgent.status == inf_stat
        beta_agent = AnimalAgent.status == :IR ? AnimalAgent.bactopop_r : AnimalAgent.bactopop_is
        if rand(animalModel.rng) < beta_agent
            interacting_agent.status = to_stat
            interacting_agent.submodel.total_status = to_stat
            interacting_agent.days_exposed =1 
            transmission = "Transmission from agent!"
        else
            transmission = "No transmission"
        end
    else
        transmission = "Neither infected"
    end
return transmission

end