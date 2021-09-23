
    function treatment!(BacterialAgent, bacterialModel)
        
        num_sensitive = bacterialModel.num_sensitive

#=         num_sensitive = [a.status == :IS for a in allagents(bacterialModel)]
        num_sensitive = sum(num_sensitive) =#

        # Turn over agents at each timestep

        if bacterialModel.days_treated > 0
            if bacterialModel.total_status == :IR || bacterialModel.total_status == :IS
                if BacterialAgent.status == :IS
                    if rand(animalModel.rng) < ℯ^(-bacterialModel.days_treated/10)
                        if bacterialModel.total_status == :CS && num_sensitive > bacterialModel.min_sensitive
                            kill_agent!(BacterialAgent, bacterialModel)
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
    end
