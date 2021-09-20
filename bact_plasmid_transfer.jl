function bact_plasmid_transfer!(BacterialAgent, bacterialModel)

    for neighbor in nearby_agents(BacterialAgent, bacterialModel)
        if BacterialAgent.status == :R && (neighbor.status == :IS || neighbor.status == :S)
            if rand(bacterialModel.rng) < 1e-2/time_units
                neighbor.status = BacterialAgent.status
                neighbor.strain = BacterialAgent.strain
            end
        end
    end
end
