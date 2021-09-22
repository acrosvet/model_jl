function bact_treatment_response!(BacterialAgent, bacterialModel)

    num_susceptible = [a.status == :S for a in allagents(bacterialModel)]
    num_susceptible = sum(num_susceptible)

    if bacterialModel.days_treated > 0 && (BacterialAgent.status == :IS || BacterialAgent.status == :S)
        if rand(bacterialModel.rng) < ℯ^(-bacterialModel.days_treated/10)
            #if rand(bacterialModel.rng) < 0.5
                if num_susceptible > 100
                    kill_agent!(BacterialAgent, bacterialModel)
                end
           #end
        end
    end


end