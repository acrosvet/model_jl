function fitness!(BacterialAgent, bacterialModel)
    if haskey(bacterialModel.agents, BacterialAgent.id) == true  
        for neighbor in nearby_agents(BacterialAgent, bacterialModel)
            if haskey(bacterialModel.agents, neighbor.id) == true
                if BacterialAgent.fitness > neighbor.fitness
                    if rand(bacterialModel.rng) < 0.05
                        neighbor.status = BacterialAgent.status
                        neighbor.strain = BacterialAgent.strain
                    end
                end
            end
        end
    end
end