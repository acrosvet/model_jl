function bact_plasmid_transfer!(BacterialAgent, bacterialModel)

    if haskey(bacterialModel.agents, BacterialAgent.id) ==  true
        for neighbor in nearby_agents(BacterialAgent, bacterialModel)
            if haskey(bacterialModel.agents, neighbor.id) ==  true
                if BacterialAgent.status == :R && (neighbor.status == :IS || neighbor.status == :S)
                    if rand(bacterialModel.rng) < 0.005
                            neighbor.status = BacterialAgent.status
                            neighbor.strain = BacterialAgent.strain
                    end
                end
            end
        end
    end
end
