function invasion!(BacterialAgent, bacterialModel)

 # If the animal is exposed but not recovered, pathogenic bacteria can outcompete existing bacteria.
    if bacterialModel.days_exposed != 0 && bacterialModel.days_recovered == 0
        #println("evaluating")
            possible_interactions =  collect(nearby_ids(BacterialAgent, bacterialModel, (1, 1)))#Determine the neighbours of each agent
            num_contacts = length(possible_interactions)#Determine the number of contacts
            status_agent = BacterialAgent.status#Determine the status of the agent
        
        if length(possible_interactions) > 0 #If there are interactions
            @async Threads.@threads for i in 1:length(possible_interactions)
                if haskey(bacterialModel.agents, possible_interactions[i])
                    interacting_agent = bacterialModel[possible_interactions[i]]
                    interacting_id = interacting_agent.id
                    num_contacts = length(possible_interactions) #Iterate through them
                    status_agent = BacterialAgent.status
                    interacting_status = interacting_agent.status

                    if interacting_status == :S
                        if BacterialAgent.status == :IS && bacterialModel.total_status == :ES #Sensitive agents compete with pathogenic agents
                        # println("Condition 1 met")
                                if rand(bacterialModel.rng) < 0.5
                                    if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                        if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                                            #println("IS invasion!")
                                            bacterialModel[interacting_id].strain = BacterialAgent.strain
                                            bacterialModel[interacting_id].status = BacterialAgent.status
                                            bacterialModel.num_susceptible -= 1
                                        end
                                    end
                                end
                        elseif BacterialAgent.status == :R && bacterialModel.total_status == :ER
                            if rand(bacterialModel.rng) < 0.5    
                                if haskey(bacterialModel.agents, interacting_id) && haskey(bacterialModel.agents, BacterialAgent.id)
                                    if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                                        #println("IR invasion")
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
        end

    end

end