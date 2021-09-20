function bact_treatment_response!(BacterialAgent, bacterialModel)

    if bacterialModel.days_treated > 0 && (BacterialAgent.status == :IS || BacterialAgent.status == :S)
        if rand(bacterialModel.rng) < ℯ^(-bacterialModel.days_treated/10)
            if rand(bacterialModel.rng) > 0.5
                kill_agent!(BacterialAgent, bacterialModel)
            end
        end
    end


end