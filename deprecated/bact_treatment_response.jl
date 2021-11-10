function bact_treatment_response!(BacterialAgent, bacterialModel)


    if bacterialModel.days_treated > 0 && (BacterialAgent.status == :IS || BacterialAgent.status == :S)
        if rand(bacterialModel.rng) < ℯ^(-bacterialModel.days_treated/20)
            #if rand(bacterialModel.rng) < 0.5
                if bacterialModel.num_susceptible > bacterialModel.min_susceptible
                    if haskey(bacterialModel.agents, BacterialAgent.id)
                        kill_agent!(BacterialAgent, bacterialModel)
                        if BacterialAgent.status == :IS
                            bacterialModel.num_sensitive -= 1
                        elseif BacterialAgent.status == :S
                            bacterialModel.num_susceptible -= 1
                        end
                    end
                end
           #end
        end
    end


end