function bact_plasmid_transfer!(BacterialAgent, bacterialModel)


    possible_interactions =  collect(nearby_ids(BacterialAgent, bacterialModel, (1, 1)))
    num_contacts = length(possible_interactions)
    status_agent = BacterialAgent.status
    if length(possible_interactions) > 0
         for i in 1:length(possible_interactions)
            if haskey(bacterialModel.agents, possible_interactions[i])
            interacting_agent = bacterialModel[possible_interactions[i]]
            interacting_id = interacting_agent.id
            num_contacts = length(possible_interactions)
            status_agent = BacterialAgent.status
            interacting_status = interacting_agent.status

            if BacterialAgent.status == :R && (interacting_status == :IS || interacting_status == :S)
                if rand(bacterialModel.rng) < 0.005
                    if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                        if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                            bacterialModel[interacting_id].strain = BacterialAgent.strain
                            bacterialModel[interacting_id].status = BacterialAgent.status
                            bacterialModel[interacting_id].fitness = BacterialAgent.fitness
                            if interacting_status == :S
                                bacterialModel.num_susceptible -= 1
                            elseif interacting_status == :IS
                                bacterialModel.num_sensitive -= 1
                            end
                        end
                    end
                end
            end
        end
        end
    end



end
