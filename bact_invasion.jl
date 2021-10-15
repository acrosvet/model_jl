function invasion!(BacterialAgent, bacterialModel)

    num_resistant = [a.status == :R for a in allagents(bacterialModel)]
    bacterialModel.num_resistant = sum(num_resistant)

    num_susceptible = [a.status == :S for a in allagents(bacterialModel)]
    bacterialModel.num_susceptible = sum(num_susceptible)


    if bacterialModel.days_exposed != 0 && bacterialModel.days_recovered == 0
        #println("evaluating")
            possible_interactions =  collect(nearby_ids(BacterialAgent, bacterialModel, (1, 1)))
            num_contacts = length(possible_interactions)
            status_agent = BacterialAgent.status
        
        if length(possible_interactions) > 0
           Threads.@threads for i in 1:length(possible_interactions)
                if haskey(bacterialModel.agents, possible_interactions[i])
                    interacting_agent = bacterialModel[possible_interactions[i]]
                    interacting_id = interacting_agent.id
                    num_contacts = length(possible_interactions)
                    status_agent = BacterialAgent.status
                    interacting_status = interacting_agent.status

                    if interacting_status == :S
                        if BacterialAgent.status == :IS && (bacterialModel.total_status == :ES)
                        # println("Condition 1 met")
                                if rand(bacterialModel.rng) < 0.5
                                    if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                        if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                                            #println("IS invasion!")
                                            bacterialModel[interacting_id].strain = BacterialAgent.strain
                                            bacterialModel[interacting_id].status = BacterialAgent.status
                                        end
                                    end
                                end
                        elseif BacterialAgent.status == :R && (bacterialModel.total_status == :ER)
                            if rand(bacterialModel.rng) < 0.5    
                                if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                    if (bacterialModel.num_resistant > bacterialModel.min_resistant) && (bacterialModel.num_susceptible > bacterialModel.min_susceptible)
                                        #println("IR invasion")
                                        bacterialModel[interacting_id].strain = BacterialAgent.strain
                                        bacterialModel[interacting_id].status = BacterialAgent.status
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

    end

end