function bact_recovery!(BacterialAgent, bacterialModel)

    if bacterialModel.total_status == :recovered
            if rand(bacterialModel.rng) < ℯ^(-bacterialModel.days_recovered/50)
                if (bacterialModel.num_resistant > bacterialModel.min_resistant) && BacterialAgent.status == :R
                    if haskey(bacterialModel.agents, BacterialAgent.id)
                        kill_agent!(BacterialAgent, bacterialModel)
                        bacterialModel.num_resistant -= 1
                    end
                elseif BacterialAgent.status == :IS 
                    if haskey(bacterialModel.agents, BacterialAgent.id)
                        kill_agent!(BacterialAgent, bacterialModel)
                        bacterialModel.num_sensitive -= 1
                    end
                end
            end
    end

end