function bact_plasmid_transfer!(BacterialAgent, bacterialModel)

    for neighbor in nearby_agents(BacterialAgent, bacterialModel)
        if BacterialAgent.status == :R && (neighbor.status == :IS || neighbor.status == :S)
            if rand(bacterialModel.rng) < 0.05
                    neighbor.status = BacterialAgent.status
                    neighbor.strain = BacterialAgent.strain
            end
        end
    end
end
