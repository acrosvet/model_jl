function infection!(BacterialAgent, bacterialModel)
    num_susceptible = [a.status == :S for a in allagents(bacterialModel)]
    num_susceptible = sum(num_susceptible)

    if bacterialModel.total_status == :ES && bacterialModel.days_exposed == 1
        pathogenic_strain = 1
        while pathogenic_strain == bacterialModel.r_strain
            pathogenic_strain += 1
        end
        if BacterialAgent.id % 3 == 0 && BacterialAgent.strain != bacterialModel.r_strain
            if num_susceptible > 100
                BacterialAgent.strain = pathogenic_strain
            end
        end
        if BacterialAgent.strain == pathogenic_strain
            if num_susceptible > 100
                BacterialAgent.status = :IS
                bacterialModel.strain_statuses[pathogenic_strain] = :IS
            end
        end
    elseif bacterialModel.total_status == :ER && bacterialModel.days_exposed == 1
        r_strain = bacterialModel.r_strain
        if BacterialAgent.id % 3 == 0
            if num_susceptible > 100
                BacterialAgent.strain = r_strain
            end
        end
        if BacterialAgent.strain == r_strain
            if num_susceptible > 100
                BacterialAgent.status = :R
                bacterialModel.strain_statuses[r_strain] = :R
            end
        end
    end

end

