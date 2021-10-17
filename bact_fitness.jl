function fitness!(BacterialAgent, bacterialModel)

        possible_interactions =  collect(nearby_ids(BacterialAgent, bacterialModel, (1, 1)))
        num_contacts = length(possible_interactions) 
        status_agent = BacterialAgent.status
        if length(possible_interactions) > 0
            Threads.@threads  for i in 1:length(possible_interactions)
                if haskey(bacterialModel.agents, possible_interactions[i])
                    interacting_agent = bacterialModel[possible_interactions[i]]
                    interacting_id = interacting_agent.id
                    num_contacts = length(possible_interactions)
                    status_agent = BacterialAgent.status
                    interacting_fitness = interacting_agent.fitness

                    if BacterialAgent.fitness > interacting_fitness
                        #if rand(bacterialModel.rng) < 0.05
                        if interacting_agent.status == :R && (bacterialModel.num_resistant > bacterialModel.min_resistant) 
                            if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                    bacterialModel[interacting_id].strain = BacterialAgent.strain
                                    bacterialModel[interacting_id].status = BacterialAgent.status
                                    bacterialModel.num_resistant -=1 
                            end
                        elseif interacting_agent.status == :S && (bacterialModel.num_susceptible > bacterialModel.min_susceptible) 
                            if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                bacterialModel[interacting_id].strain = BacterialAgent.strain
                                bacterialModel[interacting_id].status = BacterialAgent.status
                                bacterialModel.num_susceptible -= 1
                            end
                        end
                    end
                end
            end
        end

end