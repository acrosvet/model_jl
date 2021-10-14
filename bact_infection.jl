function infection!(BacterialAgent, bacterialModel)

    num_resistant = [a.status == :R for a in allagents(bacterialModel)]
    bacterialModel.num_resistant = sum(num_resistant)

    num_susceptible = [a.status == :S for a in allagents(bacterialModel)]
    bacterialModel.num_susceptible = sum(num_susceptible)

if bacterialModel.num_susceptible > bacterialModel.min_susceptible


    if bacterialModel.total_status == :ES && bacterialModel.days_exposed == 1
        pathogenic_strain = 1
        while pathogenic_strain == bacterialModel.r_strain
            pathogenic_strain += 1
        end
        bacterialModel.strain_statuses[pathogenic_strain] = :IS
        if BacterialAgent.id % 4 == 0 && BacterialAgent.strain != bacterialModel.r_strain
            #if (num_susceptible > bacterialModel.min_susceptible) && (bacterialModel.num_resistant > bacterialModel.min_resistant)
                BacterialAgent.strain = pathogenic_strain
                BacterialAgent.status = :IS
                BacterialAgent.fitness = bacterialModel.fitnesses[pathogenic_strain]*rand(bacterialModel.rng, 0.75:0.01:0.9)
            #end
        end
    elseif bacterialModel.total_status == :ER && bacterialModel.days_exposed == 1
        r_strain = bacterialModel.r_strain
        if BacterialAgent.id % 4 == 0
            #if (num_susceptible > bacterialModel.min_susceptible) && (bacterialModel.num_resistant > bacterialModel.min_resistant)
                BacterialAgent.strain = r_strain
                BacterialAgent.status = :R
                BacterialAgent.fitness = bacterialModel.fitnesses[r_strain]*rand(bacterialModel.rng, 0.5:0.01:0.6)
            #end
        end
    end
end
end

