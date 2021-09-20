function infection!(BacterialAgent, bacterialModel)

    if bacterialModel.total_status == :ES
        pathogenic_strain = rand(1:nstrains)
        if BacterialAgent.strain == pathogenic_strain
            BacterialAgent.status = :IS
            bacterialModel.strain_statuses[pathogenic_strain] = :IS
        end
        if BacterialAgent.id % 4 == 0
            BacterialAgent.status = :IS
            BacterialAgent.strain = pathogenic_strain
        end
    elseif bacterialModel.total_status == :ER
        r_strain = rand(1:nstrains)
        if BacterialAgent.strain == r_strain
            BacterialAgent.status = :R
            bacterialModel.strain_statuses[pathogenic_strain] = :R
        end
        if BacterialAgent.id % 4 == 0
            BacterialAgent.status = :R
            BacterialAgent.strain = pathogenic_strain
        end
    end

end

