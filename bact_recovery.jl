function bact_recovery!(BacterialAgent, bacterialModel)
#=     num_resistant = [a.status == :R for a in allagents(bacterialModel)]
    num_resistant = sum(num_resistant) =#
    if bacterialModel.days_recovered > 0
        if BacterialAgent.status == :R || BacterialAgent.status == :IS
            if rand(bacterialModel.rng) < ℯ^(-bacterialModel.days_recovered/10)
                if (bacterialModel.num_resistant > bacterialModel.min_resistant) && BacterialAgent.status == :R
                    kill_agent!(BacterialAgent, bacterialModel)
                elseif BacterialAgent.status == :IS 
                    kill_agent!(BacterialAgent, bacterialModel)
                end
            end
        end
    end

end