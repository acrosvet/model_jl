function fitness!(BacterialAgent, bacterialModel)
    
    for neighbor in nearby_agents(BacterialAgent, bacterialModel)
        if BacterialAgent.fitness > neighbor.fitness
            if rand(bacterialModel.rng) > 0.5
                neighbor.status = BacterialAgent.status
                neighbor.strain = BacterialAgent.strain
            end
        end
    end

end