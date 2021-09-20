
    function treatment!(BacterialAgent, bacterialModel)
        
        # Turn over agents at each timestep

        if bacterialModel.days_treated > 0
            if bacterialModel.total_status == :IR || bacterialModel.total_status == :IS
                if BacterialAgent.status == :IS
                    if rand(animalModel.rng) < ℯ^(-bacterialModel.days_treated/10)
                        kill_agent!(BacterialAgent, bacterialModel)
                        #bacterialModel.r_strain == 0 ? bacterialModel.r_strain = max(bacterialModel.nstrains) + 1 : bacterialModel.r_strain = bacterialModel.r_strain
                        strain = bacterialModel.r_strain
                        pos = BacterialAgent.pos
                        strain_status = bacterialModel.strain_statuses[r_strain]
                        fitness = bacterialModel.fitnesses[r_strain]
                        status = bacterialModel.strain_statuses[r_strain]
                        agent = BacterialAgent(n, pos,  status, strain, strain_status, fitness)
                        add_agent_single!(agent, bacterialModel) 
                    end
                end
            end
        end   
    end
